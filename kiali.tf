locals {
  kiali_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  kiali_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "kiali" {
  metadata {
    name   = var.kiali_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.kiali_istio_ambient_mode_labels : local.kiali_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
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
  timeout          = 1800

  set {
    name  = "cr.spec.external_services.grafana.auth.username"
    value = var.grafana_admin_user
  }

  set {
    name  = "cr.spec.external_services.grafana.auth.password"
    value = var.grafana_admin_password == "" ? random_password.grafana_admin_password[0].result : var.grafana_admin_password
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
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/kiali/ambient_istio_policies_values.yaml" : "./helm/kiali/sidecar_istio_policies_values.yaml" )
  ]
}
