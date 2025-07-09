output "primary_value" {
  description = "The random string from primary provider"
  value       = random_string.primary.result
}

output "secondary_value" {
  description = "The random string from secondary provider"
  value       = random_string.secondary.result
}