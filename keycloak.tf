locals {
  keycloak_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  keycloak_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name   = var.keycloak_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.keycloak_istio_ambient_mode_labels : local.keycloak_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "random_password" "keycloak_admin_password" {
  count = var.keycloak_admin_password == "" ? 1 : 0
  length = 32
}

resource "helm_release" "keycloak" {
  name             = "keycloak"
  repository       = "https://codecentric.github.io/helm-charts"
  chart            = "keycloak"
  namespace        = var.keycloak_namespace
  version          = var.keycloak_helm_chart_version
  values           = [file("./helm/keycloak/values.yaml")]
  timeout          = 1800

  set {
    name  = "secrets.creds.data.admin-user"
    value = base64encode(var.keycloak_admin_user)
  }

  set {
    name  = "secrets.creds.data.admin-password"
    value = var.keycloak_admin_password == "" ? base64encode(random_password.keycloak_admin_password[0].result) : base64encode(var.keycloak_admin_password)
  }

  depends_on = [ kubernetes_namespace.keycloak ]
}

resource "helm_release" "keycloak_istio_policies" {
  name      = "keycloak-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = var.keycloak_namespace
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/keycloak/ambient_istio_policies_values.yaml" : "./helm/keycloak/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.keycloak ]
}
