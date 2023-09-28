provider "helm" {
  kubernetes {
    config_path = "~/.kube/zmh-green"
  }
}

resource "helm_release" "kube_stack" {
  name             = "kube-prometheus-stack"
  cleanup_on_fail  = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  set {
    name  = "grafana.ingress.enabled"
    value = "true"
  }
  set {
    name  = "grafana.ingress.hosts[0]"
    value = "grafana.local.chillpickles.digital"
  }
  set {
    name  = "grafana.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
}