resource "random_string" "primary" {
  length  = var.length
  special = false
}

resource "random_string" "secondary" {
  provider = random.secondary
  length   = var.length
  special  = false
}
