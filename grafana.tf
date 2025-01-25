locals {
  grafana_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  grafana_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name   = var.grafana_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.grafana_istio_ambient_mode_labels : local.grafana_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "random_password" "grafana_admin_password" {
  count = var.grafana_admin_password == "" ? 1 : 0
  length = 32
}

resource "helm_release" "grafana" {
  name             = "grafana"

  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = var.grafana_namespace
  version          = var.grafana_helm_chart_version
  values           = [ file("./helm/grafana/values.yaml") ]
  timeout          = 1800

  set {
    name  = "adminUser"
    value = var.grafana_admin_user
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password == "" ? random_password.grafana_admin_password[0].result : var.grafana_admin_password
  }

  depends_on = [ kubernetes_namespace.grafana ]
}

resource "helm_release" "grafana_istio_policies" {
  name      = "grafana-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.grafana.id
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/grafana/ambient_istio_policies_values.yaml" : "./helm/grafana/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.grafana ]
}
