variable "api_gateway_name" {
    type = string
    description =  "the name of the apigateway."
}

variable "resources" { 
    type = map(map(string))
    description = "resources variables is where we deploy each resource, and each one of them is a resource wiht an api manage by apigateway"
}

variable "get_methods" {
    type = map(map(string))
    description = "Get methods for each resource."
}

