resource "kubernetes_service" "this" {
  metadata {
    name      = test
    namespace = var.namespace
    labels = merge(local.common_labels, {
      "app.kubernetes.io/component" = "backend"
    })
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
    selector = merge(local.common_labels, {
      "app.kubernetes.io/component" = "backend"
    })
  }
}