locals {
  prometheus_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  prometheus_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name   = var.prometheus_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.prometheus_istio_ambient_mode_labels : local.prometheus_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
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
  timeout          = 1800

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
  timeout          = 1800

  depends_on = [ helm_release.prometheus ]
}

resource "helm_release" "prometheus_istio_policies" {
  name      = "prometheus-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.prometheus.id
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/prometheus/ambient_istio_policies_values.yaml" : "./helm/prometheus/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.prometheus ]
}
