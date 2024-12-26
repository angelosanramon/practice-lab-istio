# resource "kubernetes_namespace" "istio" {
#   metadata {
#     name   = var.istio_namespace

#     labels = {
#       istio-injection = "enabled"
#     }
#   }
# }

resource "helm_release" "istio_base" {
  name             = "istio-base"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
}

resource "helm_release" "istiod" {
  name             = "istio-control-plane"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
  values           = [ file("./helm/istio/istiod_values.yaml") ]

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  depends_on = [ helm_release.istio_base ]
}

resource "helm_release" "istio_ingressgateway" {
  name             = "istio-ingressgateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = var.istio_helm_chart_version

  depends_on = [
    helm_release.istio_base, 
    helm_release.istiod
  ]
}

resource "helm_release" "istio_egressgateway" {
  name             = "istio-egressgateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-egress"
  create_namespace = true
  version          = var.istio_helm_chart_version
  values = [ file("./helm/istio/egress_gateway_values.yaml") ]

  depends_on = [
    helm_release.istio_base, 
    helm_release.istiod
  ]
}
