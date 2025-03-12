# k3s Configuration

## Management Cluster:

### <u>RPI prep</u>
need to install on ARM servers: https://github.com/rancher/k3os/issues/702#issuecomment-850246749

`apt install apparmor apparmor-utils -y`

for `RaspiOS` need to add the values to `/boot/cmdline.txt`
 - `cgroup_memory=1`
 - `cgroup_enable=memory`

#### [all values must match across all of the servers configured for a cluster](https://docs.k3s.io/cli/server#critical-configuration-values)

We're abandoning the experimental etcd only cluster that was a misinformed mess, currently we just need a standalone server and a single agent

```curl -fL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s --cluster-init --disable traefik --disable servicelb --secrets-encryption=true --flannel-backend host-gw --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16```

- `INSTALL_K3S_EXEC=` when you execute `k3s` commands, you can choose to run `k3s server` or `k3s agent`, this option passes that option to the execution of this script. IF YOU ARE RUNNING commands with config files in place, the script will look for the `server/token` entries to determine if it's going to start as a server or agent? (maybe not true, in testing I had to run it with agent passed, will figure out what I did wrong later)
- `cluster-init` [bool] passed when creating a new cluster instead of joining an existing one
- `--disable traefik --disable servicelb` we do not want these addons to be activated at launch, we're using ingress-nginx and metallb to perform these functions
- `secrets-encryption true` encrypt secrets at rest. can be better managed when we are self managing the secrets that are used to encrypt said secrets, but encrypting the secrets that encrypt the secrets is a problem for a different me
- `--flannel-backend host-gw` [docs](https://docs.k3s.io/installation/network-options#flannel-options) allows flannel to route traffic between pods using node IP addresses. Kinda hacky, might replace with calico when I'm feeling brave
- `--cluster-cidr` cidr for pods
- `--service-cidr` cidr for services
- `--cluster-dns` IPv4 Cluster IP for coredns service. Should be in your service-cidr range

"In addition to configuring K3s with environment variables and CLI arguments, K3s can also use a config file. By default, values present in a YAML file located at /etc/rancher/k3s/config.yaml will be used on install"

### Server config.yaml

```
cluster-init: true
disable:
 - "traefik"
 - "servicelb"
secrets-encryption: true
flannel-backend:
 - "host-gw"
cluster-cidr: "10.42.0.0/16"
service-cidr: "10.43.0.0/16"
```

so the command to invoke the k3s install on the server will be
`curl -fL https://get.k3s.io | sh -s`
and this will work as long as the config file is in the correct location

The kubeconfig is stored at this location

    sudo cat /etc/rancher/k3s/k3s.yaml

The node token to add server nodes to the cluster is at this location

    sudo cat /var/lib/rancher/k3s/server/node-token

### Agent config.yaml

```
server: "https://10.79.1.30:6443"
token: ""
```

invoked with 
`curl -fL https://get.k3s.io | INSTALL_K3S_EXEC="agent --config /etc/rancher/k3s/config.yaml" sh -s`
