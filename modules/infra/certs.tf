resource "kubectl_manifest" "ca_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
  YAML

  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cert_manager
  ]
}

resource "kubectl_manifest" "asrnet_ca_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: asrnet-ca-cert
  namespace: cert-manager
spec:
  isCA: true
  secretName: asrnet.com-ca-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "argocd,bookinfo,grafana,kiali,jaeger,prometheus,keycloak,vault,jenkins"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "argocd,bookinfo,grafana,kiali,jaeger,prometheus,keycloak,vault,jenkins"
  commonName: asrnet.com
  dnsNames:
    - asrnet.com
  issuerRef:
    name: ca-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cert_manager
  ]
}

resource "kubectl_manifest" "bookinfo_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: bookinfo-issuer
  namespace: bookinfo
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.bookinfo
  ]
}

resource "kubectl_manifest" "bookinfo_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: bookinfo-cert
  namespace: bookinfo
spec:
  secretName: bookinfo.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: bookinfo.asrnet.com
  dnsNames:
    - bookinfo.asrnet.com
  issuerRef:
    name: bookinfo-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.bookinfo
  ]
}

resource "kubectl_manifest" "argocd_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: argocd-issuer
  namespace: argocd
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "argocd_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-cert
  namespace: argocd
spec:
  secretName: argocd.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: argocd.asrnet.com
  dnsNames:
    - argocd.asrnet.com
  issuerRef:
    name: argocd-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "grafana_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: grafana-issuer
  namespace: grafana
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.grafana
  ]
}

resource "kubectl_manifest" "grafana_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-cert
  namespace: grafana
spec:
  secretName: grafana.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: grafana.asrnet.com
  dnsNames:
    - grafana.asrnet.com
  issuerRef:
    name: grafana-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.grafana
  ]
}

resource "kubectl_manifest" "jaeger_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: jaeger-issuer
  namespace: jaeger
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.jaeger
  ]
}

resource "kubectl_manifest" "jaeger_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: jaeger-cert
  namespace: jaeger
spec:
  secretName: jaeger.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: jaeger.asrnet.com
  dnsNames:
    - jaeger.asrnet.com
  issuerRef:
    name: jaeger-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.jaeger
  ]
}

resource "kubectl_manifest" "kiali_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: kiali-issuer
  namespace: kiali
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.kiali_operator
  ]
}

resource "kubectl_manifest" "kiali_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kiali-cert
  namespace: kiali
spec:
  secretName: kiali.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: kiali.asrnet.com
  dnsNames:
    - kiali.asrnet.com
  issuerRef:
    name: kiali-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.kiali_operator
  ]
}

resource "kubectl_manifest" "prometheus_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: prometheus-issuer
  namespace: prometheus
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "prometheus_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: prometheus-cert
  namespace: prometheus
spec:
  secretName: prometheus.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: prometheus.asrnet.com
  dnsNames:
    - prometheus.asrnet.com
  issuerRef:
    name: prometheus-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "keycloak_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: keycloak-issuer
  namespace: keycloak
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.keycloak
  ]
}

resource "kubectl_manifest" "keycloak_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: keycloak-cert
  namespace: keycloak
spec:
  secretName: keycloak.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: keycloak.asrnet.com
  dnsNames:
    - keycloak.asrnet.com
  issuerRef:
    name: keycloak-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.keycloak
  ]
}

resource "kubectl_manifest" "vault_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: vault
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.vault
  ]
}

resource "kubectl_manifest" "vault_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: vault-cert
  namespace: vault
spec:
  secretName: vault.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: vault.asrnet.com
  dnsNames:
    - vault.asrnet.com
  issuerRef:
    name: vault-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.vault
  ]
}

resource "kubectl_manifest" "jenkins_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: jenkins-issuer
  namespace: jenkins
spec:
  ca:
    secretName: asrnet.com-ca-cert
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.jenkins
  ]
}

resource "kubectl_manifest" "jenkins_cert" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: jenkins-cert
  namespace: jenkins
spec:
  secretName: jenkins.asrnet.com-cert
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress"
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress"
  commonName: jenkins.asrnet.com
  dnsNames:
    - jenkins.asrnet.com
  issuerRef:
    name: jenkins-issuer
    kind: Issuer
    group: cert-manager.io
  YAML

  depends_on = [
    helm_release.cert_manager,
    helm_release.jenkins
  ]
}
