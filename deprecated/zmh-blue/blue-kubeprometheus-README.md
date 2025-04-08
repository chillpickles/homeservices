## 20250312

great, no instruction from the late great genius on how to find `[RELEASE_NAME]` for running helm commands

```
helm search repo prometheus - returns a list of charts in the prometheus repo that has been added locally

helm install [<your personalized name for the release>] prometheus-community/kube-prometheus-stack

if you wanna use a values.yaml file?

helm install -f values.yaml --generate-name prometheus-community/kube-prometheus-stack

helm -n <namespace> upgrade -f values.yaml <install name> prometheus-community/kube-prometheus-stack
```

and then we pray that poor RPI3 can take this beating