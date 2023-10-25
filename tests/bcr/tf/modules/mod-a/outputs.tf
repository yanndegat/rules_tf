output "strings" {
  description = "return a map of strings"
  value = {
    input_string  = var.a_string
    random_string = random_string.a_random_string.result
  }
}
