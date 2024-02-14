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
