locals {
  vault_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  vault_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name   = var.vault_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.vault_istio_ambient_mode_labels : local.vault_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "random_password" "vault_unseal_keys_reader_password" {
  count  = var.vault_unseal_keys_reader_password == "" ? 1 : 0
  length = 32
}

resource "kubectl_manifest" "vault_unseal_keys_reader_creds" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: vault-unseal-keys-reader-creds
  namespace: ${var.vault_namespace}
data:
  unseal-keys-reader-user: ${base64encode(var.vault_unseal_keys_reader_user)}
  unseal-keys-reader-password: ${base64encode(var.vault_unseal_keys_reader_password == "" ? random_password.vault_unseal_keys_reader_password[0].result : var.vault_unseal_keys_reader_password)}
  YAML

  depends_on = [ kubernetes_namespace.vault ]
}

resource "kubectl_manifest" "vault_init_unseal_configmap" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-init-unseal
  namespace: ${var.vault_namespace}
data:
  init-unseal.sh: |
    #!/bin/sh

    # Waiting if vault server is not started.
    while true ; do
        vault status 
        [[ $? -eq 1 ]] || break
    done

    NUM_KEYS=3

    # Initialize Vault
    if [ $(vault status | grep Initialized | awk '{print $2}') == "false" ]; then
        vault operator init -key-shares=$NUM_KEYS > /home/vault/seal-keys
    fi

    # Unseal Vault
    if [ $(vault status | grep Sealed | awk '{print $2}') == "true" ]; then
        for i in $(seq 1 $NUM_KEYS) ; do
            vault operator unseal $(grep "Key $i" /home/vault/seal-keys | awk -F: '{print $2}') 
        done
    fi

    export VAULT_TOKEN=$(grep "Initial Root Token" /home/vault/seal-keys | awk -F': ' '{print $2}')

    # Enable userpass auth engine
    if [ "$(vault auth list | grep userpass)" == "" ]; then
        vault auth enable userpass
    fi

    # Enable KV v2 secret engine
    if [ "$(vault secrets list | grep kv-v2)" == "" ]; then
        vault secrets enable kv-v2
    fi

    # Save initial root token and unseal keys to Vault
    keys=""
    for i in $(seq 1 $NUM_KEYS) ; do
        key="$(grep "Key $i" /home/vault/seal-keys | awk -F': ' '{print $2}')"
        keys="$keys unseal-key$i=$key "
    done
    keys="$keys initial-root-token=$VAULT_TOKEN"
    vault kv put kv-v2/vault/unseal-keys $keys

    # Create user with access to the unseal keys
    cat <<EOF > /home/vault/unseal-keys-reader.hcl
    path "kv-v2/*" {
      capabilities = ["list"]
    }

    path "kv-v2/data/vault/unseal-keys" {
      capabilities = ["read"]
    }
    EOF
    vault policy write unseal-keys-reader /home/vault/unseal-keys-reader.hcl
    vault write auth/userpass/users/${var.vault_unseal_keys_reader_user} \
        password="${var.vault_unseal_keys_reader_password == "" ? random_password.vault_unseal_keys_reader_password[0].result : var.vault_unseal_keys_reader_password}" \
        policies=unseal-keys-reader

    # Clean up
    rm -f /home/vault/seal-keys
    rm -f /home/vault/unseal-keys-reader.hcl
  YAML

  depends_on = [ kubernetes_namespace.vault ]
}

resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = var.vault_namespace
  version          = var.vault_helm_chart_version
  values           = [file("./helm/vault/values.yaml")]
  timeout          = 3600

  depends_on = [
    kubernetes_namespace.vault,
    kubectl_manifest.vault_init_unseal_configmap
  ]
}

resource "helm_release" "vault_istio_policies" {
  name      = "vault-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = var.vault_namespace
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/vault/ambient_istio_policies_values.yaml" : "./helm/vault/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.vault ]
}
