output "primary_random" {
  description = "Random string from primary provider"
  value       = module.multi_provider_example.primary_value
}

output "secondary_random" {
  description = "Random string from secondary provider"
  value       = module.multi_provider_example.secondary_value
}