variable "prefix" {}
variable "environment" {}
variable "location" {}
variable "owner" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-tfe-rg"
  location = "${var.location}"

  tags = {
    "environment" = "${var.environment}"
    "owner" = "${var.owner}"
  }
}
