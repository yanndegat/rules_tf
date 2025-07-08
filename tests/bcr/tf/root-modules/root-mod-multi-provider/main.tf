# Configure two provider instances for different purposes
provider "random" {
  alias = "primary"
}

provider "random" {
  alias = "secondary"
}

# Use the multi_provider module with both provider configurations
module "multi_provider_example" {
  source = "../../modules/multi_provider"

  providers = {
    random.primary   = random.primary
    random.secondary = random.secondary
  }

  length = 12
}
