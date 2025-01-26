locals {
  cert_manager_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  cert_manager_istio_sidecar_mode_labels = {}
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name   = var.cert_manager_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.cert_manager_istio_ambient_mode_labels : local.cert_manager_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = var.cert_manager_namespace
  version          = var.cert_manager_helm_chart_version
  values           = [ file("./helm/cert-manager/values.yaml") ]
  timeout          = 3600

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

resource "helm_release" "cert_manager_istio_policies" {
  count     = var.istio_mesh_mode == "sidecar" ? 1 : 0
  name      = "cert-manager-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = var.cert_manager_namespace
  values    = [
    file("./helm/cert-manager/sidecar_istio_policies_values.yaml")
  ]

  depends_on = [ helm_release.cert_manager ]
}
