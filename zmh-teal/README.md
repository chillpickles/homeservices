## 20250404

# bootstrap day!

server config in a YAML file located at `/etc/rancher/k3s/config.yaml`

```
cluster-init: true
disable:
 - "traefik"
 - "servicelb"
secrets-encryption: true
flannel-backend:
 - "host-gw"
cluster-cidr: "10.44.0.0/16"
service-cidr: "10.45.0.0/16"
etcd-snapshot-retention: "15"
etcd-s3: true
etcd-s3-endpoint: "http://s3.lavender.chillpickles.digital"
etcd-s3-access-key: ""
etcd-s3-secret-key: ""
etcd-s3-bucket: "infra-backups"
etcd-s3-folder: "zmh-teal"
```

testing out automated s3-backups

invoked with `curl -fL https://get.k3s.io | sh -s`

The kubeconfig is stored at this location

    sudo cat /etc/rancher/k3s/k3s.yaml

The node token to add server nodes to the cluster is at this location

    sudo cat /var/lib/rancher/k3s/server/node-token

agent config in a YAML file located at `/etc/rancher/k3s/config.yaml`

```
server: "https://10.79.0.153:6443"
token: ""
node-label:
    - "cpu="
    - "mem="
node-taint
```

invoked with 
`curl -fL https://get.k3s.io | INSTALL_K3S_EXEC="agent --config /etc/rancher/k3s/config.yaml" sh -s`

uninstall:

`/usr/local/bin/k3s-uninstall.sh`

`/usr/local/bin/k3s-agent-uninstall.sh`

---

#