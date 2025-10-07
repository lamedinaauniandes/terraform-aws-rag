module "rest_api" {
  source           = "./module_api_rest"
  api_gateway_name = "rag-api-gateway"
  resources        = var.resources
  lambdas          = var.lambdas
  role_lambda      = var.role_lambda
}

# ### DECLARE RESOURCES
variable "resources" {
  type = map(map(string))
  default = {
    resource_rag = {
      name_resource = "resource_rag"
      get_method    = "true"
      post_method   = "true"
      delete_method = "false"
      # name_lambda = "lambda_rag"     ## put the key name of the lambda declared
    }
    resource_consult = {
      name_resource = "resource_consult"
      get_method    = "true"
      post_method   = "true"
      delete_method = "false"
      # name_lambda = "none"
    }
  }
}

## DECLARE ROLE TO LAMBDAS 
variable "role_lambda" {
  type = map(string)
  default = {
    name = "lambda_role_rest"
  }

}

### DECLARE LAMBDAS
variable "lambdas" {
  type = map(map(string))
  default = {
    lambda_rag = {
      name_lambda = "lambda_rag"
      source_file = "../lambda_functions/lmbd_rag.py"
      output_path = "../lambda_functions/lmbd_rag.zip"
      handler     = "lmbd_rag.handler"
      runtime     = "python3.12"
      timeout     = 5
    }
  }
}

