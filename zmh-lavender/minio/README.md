## 20250318

`kubectl kustomize https://github.com/minio/operator/examples/kustomization/base/ > tenant-base.yaml`

the minio operator seems kinda cool, and I'll keep the config in here for now - but this is not at all useable at this point

[docs](https://min.io/docs/minio/container/index.html) - just running the container on host, gonna have to bind it to a node so that the volume contents don't change
and then we'll

## 20250321

had to tweak the docker container a bit
- executing container commands to get it running, never done that before
- saving off credentials into the cluster manually so that we can boot up with some credentials that aren't defaults

`kubectl create secret generic minio-credentials --from-literal=username= --from-literal=password=`

- learning `mc` commands to solidify my understanding of the setup process and how it all works
- I'm not entirely certain that `MINIO_DOMAIN` is actually used or useful

