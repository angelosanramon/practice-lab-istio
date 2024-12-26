resource "kubernetes_namespace" "kiali" {
  metadata {
    name   = var.kiali_namespace

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

resource "helm_release" "kiali_operator" {
  name             = "kiali-operator"

  repository       = "https://kiali.org/helm-charts"
  chart            = "kiali-operator"
  namespace        = "kiali-operator"
  version          = var.kiali_helm_chart_version
  create_namespace = true
  values           = [ file("./helm/kiali/kiali_operator_values.yaml") ]

  set {
    name  = "cr.spec.external_services.grafana.auth.username"
    value = var.grafana_admin_username
  }

  set {
    name  = "cr.spec.external_services.grafana.auth.password"
    value = var.grafana_admin_password
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.istio_ingressgateway,
    kubernetes_namespace.kiali
  ]
}

resource "helm_release" "kiali_istio_policies" {
  name      = "kiali-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.kiali.id
  values    = [ file("./helm/kiali/istio_policies_values.yaml") ]
}
