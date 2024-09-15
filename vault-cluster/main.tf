resource "hcp_hvn" "vault_hvn" {
  hvn_id         = "hvn"
  cloud_provider = var.hcp_hvn_cloud_provider
  region         = var.region
  cidr_block     = var.hcp_hvn_cider
}

resource "hcp_vault_cluster" "vault_cluster" {
  cluster_id      = var.hcp_vault_cluster_id
  hvn_id          = hcp_hvn.vault_hvn.hvn_id
  tier            = var.hcp_vault_cluster_tier
  public_endpoint = true
}