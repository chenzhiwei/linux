# Terraform

A quick start of terraform.


## Code Structure

A terraform project usually contain following files:

* input.tfvars - the input variables that applied
* main.tf - the main logic
* each-component.tf - if the project contains too many components, then separate them into individual file
* variables.tf - to declare the variables that used in the project
* versions.tf - to restrict the terraform and provider versions
* backend.tf - to define the terraform state file location(local or in remote)
* output.tf - to define the terraform project output


## Commands

```
gcloud auth application-default login

terraform init
terraform plan -var-file input.tfvars
terraform apply -var-file input.tfvars
terraform apply -var-file input.tfvars -backend-config=xx=xx
```
