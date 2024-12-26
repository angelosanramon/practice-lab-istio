resource "kubernetes_namespace" "jaeger" {
  metadata {
    name   = var.jaeger_namespace

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

resource "helm_release" "jaeger" {
  name             = "jaeger"

  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = var.jaeger_namespace
  version          = var.jaeger_helm_chart_version
  values           = [ file("./helm/jaeger/values.yaml") ]

  depends_on = [ kubernetes_namespace.jaeger ]
}

resource "helm_release" "jaeger_istio_policies" {
  name      = "jaeger-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.jaeger.id
  values    = [ file("./helm/jaeger/istio_policies_values.yaml") ]
}
