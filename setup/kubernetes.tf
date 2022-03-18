resource "kubernetes_namespace" "exceptions_recognition_engine" {
  metadata {
    name = var.target_namespace
    labels = {
      "istio-injection": "enabled"
    }
  }
}