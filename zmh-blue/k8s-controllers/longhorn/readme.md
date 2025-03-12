# [longhorn](https://longhorn.io/docs/1.6.0/deploy/install/#installing-open-iscsi)
## a distributed block storage system for Kubernetes

have to run stateful sets in kubernetes to run things, and you've really thought about how you would backup those files? network shares sound like buckets of fun to manage? lets see how much overhead this introduces into cluster performance!

## 20240216

[Installation Requirements](https://longhorn.io/docs/1.6.0/deploy/install/#installation-requirements) seem sane, some iscsi drivers, an nsfv4 client and some cli tools

- [iscsi on coreos](https://github.com/coreos/docs/blob/master/os/iscsi.md) is disabled by default sooooo, `systemctl enable iscsid`
  - nice lets fuck up this coreos node 
        
        systemctl enable rpcbind.service 
        systemctl enable rpc-gssd.service
        
- 🙃
- 

longhorn may misbehave on coreos I can feel it coming

- armbian
        
        sudo apt install open-iscsi

pulling `v1.6.0` of the longhorn manifests
and we killed the cluster :crying: