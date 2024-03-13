# k3s configuration.. guide? 
stealing most of this from zmh-dev lmao

need to install on ARM servers: https://github.com/rancher/k3os/issues/702#issuecomment-850246749

`apt install apparmor apparmor-utils -y`

for `RaspiOS` need to add the values to `/boot/cmdline.txt`
 - `cgroup_memory=1`
 - `cgroup_enable=memory`

## [all values must match across all of the servers configured for a cluster](https://docs.k3s.io/cli/server#critical-configuration-values)

---

 first the commands to setup etcd nodes, this does not create a usable cluster, only the etcd backend to support control-plane nodes
 please follow this if you're wanting to split up these roles with dedicated control-plane, server and agent nodes


    curl -fL https://get.k3s.io | INSTALL_K3S_EXEC="--cluster-init --disable-apiserver --disable-controller-manager --disable-scheduler --disable=traefik --disable=servicelb --secrets-encryption=true --flannel-backend=host-gw --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16 --cluster-dns=10.43.0.10 --tls-san=k3s.local.chillpickles.digital" sh -s - server

  - `INSTALL_K3S_EXEC=` I have no fucking clue, i don't know why this works or what reason there is for using it in this command and none of the following commands _I am losing my mind, I could leave IT and go learn how to do maintenance on wind turbines and fucking weld undersea cables holy shit I swear I've reread the documentation over and over it just hasnt' clicked yet_
  - the `server` command tells k3s that we're installing a server not an agent, etcd and control plane nodes are `server` nodes
  - `--cluster-init` is passed to the first node in a cluster to let k3s know that it is a _new_ cluster
  - `--disable-apiserver --disable-controller-manager --disable-scheduler` are commands passed to an etcd only node to ensure that only the etcd objects are running on it
  - `--disable traefik --disable servicelb` we do not want these addons to be activated at launch, we're using ingress-nginx and metallb to perform these functions
  - `secrets-encryption true` encrypt secrets at rest. can be better managed when we are self managing the secrets that are used to encrypt said secrets, but encrypting the secrets that encrypt the secrets is a problem for a different me
  - `--flannel-backend host-gw` [docs](https://docs.k3s.io/installation/network-options#flannel-options) allows flannel to route traffic between pods using node IP addresses. Kinda hacky, might replace with calico when I'm feeling brave. I have L2 connectivity between all my nodes so this simplifies traffic between pods/ndoes
  - `--cluster-cidr` cidr for pods
  - `--service-cidr` cidr for services
  - `--cluster-dns` IPv4 Cluster IP for coredns service. Should be in your service-cidr range

The kubeconfig is stored at this location

    sudo cat /etc/rancher/k3s/k3s.yaml

The node token to add server nodes to the cluster is at this location

    sudo cat /var/lib/rancher/k3s/server/node-token

### ~~This node token needs to be copied around manually, until the idiot sysadmin decides to automate this process further~~

---

if you want to pass an IP AND a hostname you need to pass the --tls-san flag twice, once for each type of entry? I'll mess with this once I figure out if I need to add a static registration IP or some shit, I think the DNS entry is good enough for my uses and I don't need [this](https://docs.k3s.io/architecture#fixed-registration-address-for-agent-nodes)

flannel-backend can be used to enable a wireguard-native backend to support network encryption for communication between pods on different nodes. Also supported by [calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/k3s/multi-node-install)

setting up first control plane node


    curl -fL https://get.k3s.io | K3S_URL=<first-etcd-node-ip> K3S_TOKEN=$node_token sh -s - server --disable-etcd --disable=traefik --disable=servicelb --secrets-encryption=true --flannel-backend=host-gw --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16 --cluster-dns=10.43.0.10 --tls-san=k3s.local.chillpickles.digital
   
fucking sick, so this gets us a "working" cluster with 1 etcd node and 1 control plane node 🙃 now which one to add first, and how

adding more etcd nodes?


    curl -fL https://get.k3s.io | K3S_URL=https://<first-control-plane-node-ip>:6443 K3S_TOKEN=$node_token  sh -s - server --disable-apiserver --disable-controller-manager --disable-scheduler --disable=traefik --disable=servicelb --secrets-encryption=true --flannel-backend=host-gw --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16 --cluster-dns=10.43.0.10 --tls-san=k3s.local.chillpickles.digital


okay we got that working, now to add a second control-plane node? what I understand from adding these etcd nodes to the cluster, is that now `apiServer` is running on the singular control plane node, so ALL of the new nodes can be pointed here to join the cluster

    curl -fL https://get.k3s.io | K3S_URL=https://<first-control-plane-node-ip>:6443 K3S_TOKEN=$node_token sh -s - server --disable-etcd --disable=traefik --disable=servicelb --secrets-encryption=true --flannel-backend=host-gw --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16 --cluster-dns=10.43.0.10 --tls-san=k3s.local.chillpickles.digital

we now have a working cluster. I think I need a third control-plane box but if it's working it's working - pop an agent node into here and we'll have a fresh whiteboard to work on

    sudo cat /var/lib/rancher/k3s/server/agent-token

and voila

    curl -fL https://get.k3s.io | K3S_TOKEN=$agent_token sh -s - agent --server https://10.79.1.80:6443

    