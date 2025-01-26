# Kubernetes Reflector. Use for replicating secrets and config maps between namespaces.

locals {
  reflector_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  reflector_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "reflector" {
  metadata {
    name   = var.reflector_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.reflector_istio_ambient_mode_labels : local.reflector_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "reflector" {
  name             = "reflector"
  repository       = "https://emberstack.github.io/helm-charts"
  chart            = "reflector"
  namespace        = var.reflector_namespace
  version          = var.reflector_helm_chart_version
  timeout          = 3600

  depends_on = [ kubernetes_namespace.reflector ]
}

resource "helm_release" "reflector_istio_policies" {
  count     = var.istio_mesh_mode == "sidecar" ? 1 : 0
  name      = "reflector-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = var.reflector_namespace
  values    = [
    file("./helm/reflector/sidecar_istio_policies_values.yaml")
  ]

  depends_on = [ helm_release.reflector ]
}
