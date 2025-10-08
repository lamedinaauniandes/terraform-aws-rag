variable "api_gateway_name" {
    type = string
    description =  "the name of the apigateway."
}

variable "environment" {
    type = string
    description = "the name of deploy environment"
}

variable "resources" { 
    type = map(map(string))
    description = "resources variables is where we deploy each resource, and each one of them is a resource wiht an api manage by apigateway"
}

variable "role_lambda" { 
    type = map(string)
    description = "this variable delares the role for lambda functions"
}

variable "lambdas" {
    type = map(map(string))
    description = "Get methods for each resource."
}

variable "lambda_layers" { 
    type = map(map(string))
    description = "layers used by lambda functions"
}

