module "rest_api" {
  source           = "./module_api_rest"
  api_gateway_name = "rag-api-gateway"
  secrets          = var.secrets          ## var secrets is a secret file.
  secrets_policies = var.secrets_policies ## var secrets in a secrect file
  resources        = var.resources
  lambdas          = var.lambdas
  role_lambda      = var.role_lambda
  environment      = var.environment
  lambda_layers    = var.lambda_layers
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
    }
    # resource_consult = {
    #   name_resource = "resource_consult"
    #   name_lambda   = null
    #   get_method    = "true"
    #   post_method   = "true"
    #   put_method    = null
    #   delete_method = null
    # }
  }
}

### DECLARE LAMBDAS
variable "lambdas" {
  type = map(map(string))
  default = {
    lambda_rag = {
      name_lambda = "lambda_rag"
      source_file = "../lambda/lambda_functions/lmbd_rag.py"
      output_path = "../lambda/lambda_functions/lmbd_rag.zip"
      handler     = "lmbd_rag.handler"
      runtime     = "python3.12"
      timeout     = 60
      layers      = "pandas,requests,pinecone" ### put the layers separate by ',' example: pandas,pinecone,statsmodels
      secrets     = "secrets1"
    }
  }
}

## DECLARE LAMBDA LAYERS 
variable "lambda_layers" {
  type = map(map(string))
  default = {
    pandas = {
      name_layer  = "pandas"
      description = "pandas library, from ubuntu. v4"
      source_dir  = "../lambda/layers/pandas_layer"
      output_path = "../lambda/layers/pandas_layer.zip" ## zip
    }
    requests = {
      name_layer  = "requests"
      description = "requests library v4"
      source_dir  = "../lambda/layers/requests_layer"
      output_path = "../lambda/layers/requests_layer.zip"
    }
    pinecone = {
      name_layer  = "pinecone"
      description = "pinecone library v1"
      source_dir  = "../lambda/layers/pinecone_layer"
      output_path = "../lambda/layers/pinecone_layer.zip"
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


