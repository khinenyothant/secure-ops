#create network peering connection between HCP VPN and AWS VPC
resource "hcp_aws_network_peering" "dev" {
  hvn_id          = var.hvn_id
  peering_id      = "hvn-to-vpc-peer"
  peer_vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  peer_account_id = data.aws_vpc.selected.owner_id
  peer_vpc_region = data.aws_arn.vpc_region.region
}

#accept VPC peering connection request on the AWS side
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.dev.provider_peering_id
  auto_accept               = true
}

#set up aws pirvate route in HCP
resource "hcp_hvn_route" "hvn-to-aws-private" {
  for_each         = data.aws_subnet.private
  hvn_link         = data.hcp_hvn.hvn.self_link
  hvn_route_id     = each.value.id
  destination_cidr = each.value.cidr_block
  target_link      = hcp_aws_network_peering.dev.self_link
}

#set up aws db route in HCP
resource "hcp_hvn_route" "hvn-to-aws-db" {
  for_each         = data.aws_subnet.db
  hvn_link         = data.hcp_hvn.hvn.self_link
  hvn_route_id     = each.value.id
  destination_cidr = each.value.cidr_block
  target_link      = hcp_aws_network_peering.dev.self_link
}

#set up hcp route in aws private route table
resource "aws_route" "aws-private-to-hvn" {
  route_table_id            = data.aws_route_table.private_rt.id
  destination_cidr_block    = data.hcp_hvn.hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

#set up hcp route in aws db route table
resource "aws_route" "aws-db-to-hvn" {
  route_table_id            = data.aws_route_table.db_rt.id
  destination_cidr_block    = data.hcp_hvn.hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}