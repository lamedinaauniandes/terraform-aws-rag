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
resource "aws_api_get_method" "this_get_method" {
    for_each = var.get_methods
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    resource_id = aws_api_gateway_resource.this_resource[each.value["name_resource"]].id
    http_method = "GET"
    authorization = "NONE"
}

# resource "aws_api_get_method" "this_post_method" {
#     for_each = var.resources
#     rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
#     resource_id = aws_api_gateway_resource.this_resource[each.key].id
#     http_method = "POST"
#     authorization = "NONE"
# }

# resource "aws_api_get_method" "this_delete_method" {
#     for_each = var.resources
#     rest_api_id = aws_api_gateway_resource.this_resource[each.key]
# }


