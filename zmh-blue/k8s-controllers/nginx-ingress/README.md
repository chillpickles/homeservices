# [nginx-INGRESS](https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters)
## ingress-nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.

Where metallb is a loadbalancer service that deals with address allocation and external announcement, an [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

        exposes HTTP and HTTPS routes from outside the cluster to services within the cluster

since you can expose an ingress on a `nodePort`, you could just have a node that hosts the ingress controller - In zmh-green and zmh-dev I played with hooking metallb up to do this job - where the controller is assigned an IP in the network by metallb. I've got no idea if this is ideal, or what the cost is of doing it this way, it worked well enough when I needed it.

I also used `Kind: Endpoint` objects to weasel the ingress controller into serving up my NAS and other external objects via public DNS records. Also worked pretty well, no clue what complaints I will have about this later.

- another situation where I pulled the manifest directly into local - helm is recommended, so I'll refactor this eventually

## 20240214

pulled `v1.8.2`

## 20240226

changed line [365] from type NodePort to type LoadBalancer - so that metallb loadbalances the service to be exposed to LAN

## 20240312

pulling `v1.12.0`

- `kind: endpoint` manifests have been replaced with `endpointSlices` and I haven't messed with those enough. removing those entries for now, will experiment later