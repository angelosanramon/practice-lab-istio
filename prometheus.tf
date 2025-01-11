
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name   = var.prometheus_namespace

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

resource "helm_release" "prometheus" {
  name             = "prometheus"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = var.prometheus_namespace
  version          = var.prometheus_helm_chart_version
  create_namespace = true
  values           = [ file("./helm/prometheus/prometheus_values.yaml") ]

  depends_on = [ kubernetes_namespace.prometheus ]
}

resource "helm_release" "prometheus_blackbox_exporter" {
  name             = "prometheus-blackbox-exporter"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-blackbox-exporter"
  namespace        = var.prometheus_namespace
  version          = var.prometheus_blackbox_exporter_helm_chart_version
  create_namespace = true
  values           = [ file("./helm/prometheus/prometheus_blackbox_exporter_values.yaml") ]

  depends_on = [ helm_release.prometheus ]
}

resource "helm_release" "prometheus_istio_policies" {
  name      = "prometheus-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.prometheus.id
  values    = [ file("./helm/prometheus/istio_policies_values.yaml") ]

  depends_on = [ helm_release.prometheus ]
}
