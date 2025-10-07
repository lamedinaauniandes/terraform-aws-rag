resource "aws_api_gateway_rest_api" "this_apigateway" {
    name = var.api_gateway_name
    description = "REST API"
}

### declare resources
resource "aws_api_gateway_resource" "this_resource" {
    for_each = var.resources
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    parent_id = aws_api_gateway_rest_api.this_apigateway.root_resource_id
    path_part = each.value["name_resource"]
}


### declares get methods 
resource "aws_api_gateway_method" "this_get_method" { 
    for_each = { for k,v  in var.resources: k => v if v["get_method"] == "true"}

    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    resource_id = aws_api_gateway_resource.this_resource[each.value["name_resource"]].id
    http_method ="GET"
    authorization = "NONE"  ### will changes, only for dev proposes I put this.
}

### declares post methods
resource "aws_api_gateway_method" "this_post_method" {
    for_each = { for k,v in var.resources: k => v if v["post_method"] == "true"}

    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    resource_id = aws_api_gateway_resource.this_resource[each.value["name_resource"]].id
    http_method = "POST"
    authorization = "NONE"
}

### declares delete method
resource "aws_api_gateway_method" "this_delete_method" { 
    for_each = {for k,v in var.resources: k=>v if v["delete_method"] == "true"}

    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    resource_id = aws_api_gateway_resource.this_resource[each.value["name_resource"]].id 
    http_method = "DELETE"
    authorization = "NONE"

}

# ## declares of what lambda function gets permission
# resource "aws_lambda_permission" "allow_api" { 
#     for_each = var.resources
#     statement_id = "AlloAPIGatewayInvokeREST"
#     action = "lambda:InvokeFunction"
#     funtion_name = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].function_name
#     principal = "apigateway.amazonaws.com"
#     source_arn = "${}/*/{}/"
# }
