resource "kubernetes_namespace" "grafana" {
  metadata {
    name   = var.grafana_namespace

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

resource "helm_release" "grafana" {
  name             = "grafana"

  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = var.grafana_namespace
  version          = var.grafana_helm_chart_version
  values           = [ file("./helm/grafana/values.yaml") ]

  set {
    name  = "adminUser"
    value = var.grafana_admin_username
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  depends_on = [ kubernetes_namespace.grafana ]
}

resource "helm_release" "grafana_istio_policies" {
  name      = "grafana-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.grafana.id
  values    = [ file("./helm/grafana/istio_policies_values.yaml") ]
}
