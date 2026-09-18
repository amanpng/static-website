variable "ssh_private_key_path" {
  description = "The path to the local SSH private key for Ansible access"
  type        = string
  default     = "~/.ssh/terraform-ansible-key"
}
