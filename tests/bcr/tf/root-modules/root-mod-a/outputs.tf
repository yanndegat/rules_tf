output "my_output" {
  description = "output the input var"
  value       = var.input_var
}

output "mod_outputs" {
  description = "output module's outputs"
  value       = module.amodule
}
