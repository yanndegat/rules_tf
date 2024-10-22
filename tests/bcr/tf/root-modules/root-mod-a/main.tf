resource "random_string" "a_random_string" {
  length = 16
}

module "amodule" {
  source = "../../modules/mod-a"

  a_string = random_string.a_random_string.result
}

module "a2ndmodule" {
  source = "../../modules/mod-a"

  a_string = provider::terraform::decode_tfvars("a_string = \"hello\"").a_string
}
