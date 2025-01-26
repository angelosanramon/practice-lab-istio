locals {
  jaeger_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  jaeger_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "jaeger" {
  metadata {
    name   = var.jaeger_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.jaeger_istio_ambient_mode_labels : local.jaeger_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "jaeger" {
  name             = "jaeger"

  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = var.jaeger_namespace
  version          = var.jaeger_helm_chart_version
  values           = [ file("./helm/jaeger/values.yaml") ]
  timeout          = 3600

  depends_on = [ kubernetes_namespace.jaeger ]
}

resource "helm_release" "jaeger_istio_policies" {
  name      = "jaeger-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.jaeger.id
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/jaeger/ambient_istio_policies_values.yaml" : "./helm/jaeger/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.jaeger ]
}
