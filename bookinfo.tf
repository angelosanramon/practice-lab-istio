locals {
  bookinfo_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
    "istio.io/use-waypoint"   = "bookinfo-waypoint"
  }

  bookinfo_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "bookinfo" {
  metadata {
    name   = var.bookinfo_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.bookinfo_istio_ambient_mode_labels : local.bookinfo_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "bookinfo" {
  name             = "bookinfo"
  chart            = "./helm/bookinfo"
  namespace        = var.bookinfo_namespace
  version          = var.bookinfo_helm_chart_version
  timeout          = 1800

  depends_on = [ kubernetes_namespace.bookinfo ]
}

resource "helm_release" "bookinfo_istio_policies" {
  name      = "bookinfo-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.bookinfo.id
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/bookinfo/ambient_istio_policies_values.yaml" : "./helm/bookinfo/sidecar_istio_policies_values.yaml" ) 
  ]

  depends_on = [ helm_release.bookinfo ]
}
