# Dynamically provision the remote state
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "terraform-storage-rg"
    storage_account_name = "paddystatestorage"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}.tfstate"
  }
}

# Generate an AWS provider block
generate "provider" {
  # Keep provider config in a dedicated file
  # excluded from git
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
EOF
}

terraform {
  # Ensures paralellism never exceed two modules at any time
  extra_arguments "reduced_parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=2"]
  }

  extra_arguments "common_tfvars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "${get_parent_terragrunt_dir()}/tfvars/common.tfvars"
    ]
  }

  # Terragrunt auto-init isn't always reliable - run init regardless
  before_hook "auto_init" {
    commands = ["validate", "plan", "apply", "destroy", "workspace", "output", "import"]
    execute  = ["terraform", "init"]
  }

  before_hook "before_hook" {
     commands     = ["terraform apply"]
     execute      = ["echo", "Foo"]
     run_on_error = true
  }

  after_hook "after_hook" {
    commands     = ["terraform apply"]
    execute      = ["echo", "Foo1"]
    run_on_error = false
  }
}
