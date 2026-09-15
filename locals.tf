locals {
  private_endpoints = var.private_link == null ? {} : var.private_link.endpoints
}
