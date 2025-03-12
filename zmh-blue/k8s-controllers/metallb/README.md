# [MetalLB](https://metallb.universe.tf/) 
## is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

and we like loadbalancers

- I like pulling their manifest into my local env so that when I apply I'm not hopping versions
- [Issues](https://metallb.universe.tf/configuration/k3s/) page specifies that we pass `--disable=servicelb` which we've already done!

there are better ways to manage this like [kustomize](https://kustomize.io/) or [helm](https://helm.sh/)
and they might make more sense once I'm terraforming modules - refactor could include making all of this stuff with versioned helm charts to simplify my mental (and sysadmin) overhead

## 20240214

pulling `v0.14.3`

adding a `Kind: IpAddressPool` assigns a block of IPs to metallb, so that it can broadcast various services out to the network, these are set in the homelab subnet, with a block that doesn't collide with any other clusters, or the DHCP block.

I'm interested this go to try BDP configuration for the [USG-Pro-4](https://community.ui.com/questions/How-to-configure-BGP-routing-on-USG-Pro-4/ecdfecb5-a8f5-48a5-90da-cc68d054be11) since this is a [supported](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/) mode.

## 20250312

pulling `v0.14.9`

- BGP would maybe be implemented if I had multiple WANs? but my router binds those connections anyways, and that would be failover in my case. No need to experiment with BGP for now. dingus
- `apply -f` both files here
- with multiple nodes, I've thrown in an L2Advertisement manifest to make sure all my nodes announce speaker service? this probably makes for a noisy network
    ```
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: ingress-nginx-advertisement
      namespace: metallb-system
    spec:
      ipAddressPools:
      - default
      nodeSelectors:
      - matchLabels:
          kubernetes.io/hostname: zmh-rpi-002
    ```
    probably won't do that in this cluster

- current LAN is 10.79.0.0/21 (10.79.0.0-10.79.7.255)