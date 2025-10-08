resource "aws_api_gateway_rest_api" "this_apigateway" {
    name = var.api_gateway_name
    description = "REST API"
}

############ 
##  RESOURCES 
###########

### declare resources
resource "aws_api_gateway_resource" "this_resource" {
    for_each = var.resources
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    parent_id = aws_api_gateway_rest_api.this_apigateway.root_resource_id
    path_part = each.value["name_resource"]
}

###########
### METHODS GET, POST, DELETE, PUT
###########
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


resource "aws_api_gateway_method" "this_put_method" { 
    for_each = {for k,v in var.resources: k=>v if v["put_method"]=="true"}
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    resource_id = aws_api_gateway_resource.this_resource[each.value["name_resource"]].id 
    http_method = "PUT"
    authorization = "NONE"
}

##########
## INTEGRATIONS
##########

resource "aws_api_gateway_integration" "this_get_integration" {
    for_each = {for k,v in var.resources: k=>v if v["get_method"]=="true" && v["name_lambda"]!=null}
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 
    resource_id = aws_api_gateway_resource.this_resource[each.key].id 
    http_method = aws_api_gateway_method.this_get_method[each.key].http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].invoke_arn
}

resource "aws_api_gateway_integration" "this_post_integration" {
    for_each = {for k,v in var.resources: k=>v if v["post_method"]=="true" && v["name_lambda"]!=null}
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    resource_id = aws_api_gateway_resource.this_resource[each.key].id
    http_method = aws_api_gateway_method.this_post_method[each.key].http_method
    integration_http_method = "POST"
    type= "AWS_PROXY"
    uri = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].invoke_arn
}

resource "aws_api_gateway_integration" "this_put_integration" {
    for_each = {for k,v in var.resources: k=>v if v["delete_method"]=="true" && v["name_lambda"]!=null}
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    resource_id = aws_api_gateway_resource.this_resource[each.key].id
    http_method = aws_api_gateway_method.this_put_method[each.key].http_method
    integration_http_method = "POST"
    type= "AWS_PROXY"
    uri = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].invoke_arn
}

resource "aws_api_gateway_integration" "this_delete_integration" {
    for_each = {for k,v in var.resources: k=>v if v["delete_method"]=="true" && v["name_lambda"]!=null}
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    resource_id = aws_api_gateway_resource.this_resource[each.key].id
    http_method = aws_api_gateway_method.this_delete_method[each.key].http_method
    integration_http_method = "POST"
    type= "AWS_PROXY"
    uri = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].invoke_arn
}

###########
## API GATEWAY PERMISSIONS TO LAMBDAS  
###########

## declares
resource "aws_lambda_permission" "this_allow_api" { 
    for_each = { for k,v in var.resources: k=>v if v["name_lambda"] != null}
    statement_id = "AllowAPIGatewayInvokeRESTAnyStage"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.this_lambda_function[each.value["name_lambda"]].function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_api_gateway_rest_api.this_apigateway.execution_arn}/*/*"
}

#############
### deployment
#############
resource "aws_api_gateway_deployment" "this_deploy" {
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id 

    triggers = {
        redeploy = sha1(jsonencode({
            rest_api = {for res,val_res in var.resources: res => aws_api_gateway_rest_api.this_apigateway.body} 
            resources = {for res,val_res in var.resources: res => aws_api_gateway_resource.this_resource[res].id }
            get_methods = {for res,val_res in var.resources: res => aws_api_gateway_method.this_get_method[res].id }
            get_integration = {for res,val_res in var.resources: res => aws_api_gateway_integration.this_get_integration[res].id }
        }))
    }

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_api_gateway_stage" "this_stage" {
    rest_api_id = aws_api_gateway_rest_api.this_apigateway.id
    deployment_id = aws_api_gateway_deployment.this_deploy.id
    stage_name = var.environment
}