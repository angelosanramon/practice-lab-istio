module "infra" {
  source          = "./modules/infra"
  istio_mesh_mode = var.istio_mesh_mode
}
