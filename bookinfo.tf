resource "kubernetes_namespace" "bookinfo" {
  metadata {
    name   = var.bookinfo_namespace

    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.istio_ingressgateway
  ]
}

resource "helm_release" "bookinfo" {
  name             = "bookinfo"
  chart            = "./helm/bookinfo"
  namespace        = var.bookinfo_namespace
  version          = var.bookinfo_helm_chart_version

  depends_on = [ kubernetes_namespace.bookinfo ]
}

resource "helm_release" "bookinfo_istio_policies" {
  name      = "bookinfo-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.bookinfo.id
  values    = [ file("./helm/bookinfo/istio_policies_values.yaml") ]
}
