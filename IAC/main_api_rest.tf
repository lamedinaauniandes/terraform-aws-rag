module "rest_api" {
  source           = "./module_api_rest"
  api_gateway_name = "rag-api-gateway"
#   resources        = var.resources
#   get_methods      = var.get_methods
}


# ### DECLARE RESOURCES
# variable "resource" {
#   type = map(map(string))
#   default = {
#     resource_rag = {
#       name_resource = "resource_rag"
#     }
#     resource_consult = {
#       name_resource = "resource_consult"
#     }

#   }
# }

# #### DECLARE GET METHODS
# variable "get_methods" {
#   type = map(map(string))
#   default = {
#     get_method_resource_rag = {
#       name_resource = var.resource["resource_rag"]["name_resource"]
#     }
#     get_method_resource_consult = {
#       name_resource = var.resource["resource_consult"]["name_resource"]
#     }
#   }
# }

# ### DECLARE POST METHODS
