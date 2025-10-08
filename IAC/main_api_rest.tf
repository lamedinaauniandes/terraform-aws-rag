module "rest_api" {
  source           = "./module_api_rest"
  api_gateway_name = "rag-api-gateway"
  resources        = var.resources
  lambdas          = var.lambdas
  role_lambda      = var.role_lambda
  environment      = var.environment
}

variable "environment" {
  type    = string
  default = "dev"
}

# ### DECLARE RESOURCES
variable "resources" {
  type = map(map(string))
  default = {
    resource_rag = {
      name_resource = "resource_rag"
      name_lambda   = "lambda_rag" ## put the key name of the lambda declared
      get_method    = "true"
      post_method   = "true"
      put_method    = null
      delete_method = null
      deploy_get = "true"
      deploy_post = "true"
    }
    # resource_consult = {
    #   name_resource = "resource_consult"
    #   name_lambda   = null
    #   get_method    = "true"
    #   post_method   = "true"
    #   put_method    = null
    #   delete_method = null
    #   deploy_get = null 
    #   deploy_post = null

    # }
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

