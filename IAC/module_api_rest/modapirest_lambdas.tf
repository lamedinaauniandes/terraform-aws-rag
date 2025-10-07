data "archive_file" "this_lambda_zip" {
    for_each = var.lambdas
    type = "zip"
    source_file = each.value["source_file"]
    output_path = each.value["output_path"]    
}

resource "aws_iam_role" "this_lambda_role" {
    name = var.role_lambda["name"]   
    assume_role_policy = jsonencode({
        Statement = [{
            Effect = "Allow"
            Principal = {Service = "lambda.amazonaws.com"}
            Action = "sts:AssumeRole"
        }]
    })
}
## policy-role-iam-lambda
#### we need create logs in cloudwatch
resource "aws_iam_role_policy_attachment" "this_lambda_policy" { 
    role = aws_iam_role.this_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # política aws 
}

resource "aws_lambda_function" "this_lambda_function" {
    for_each = var.lambdas
    function_name = each.value["name_lambda"]
    role = aws_iam_role.this_lambda_role.arn 
    handler = each.value["handler"]
    runtime = each.value["runtime"]
    filename = data.archive_file.this_lambda_zip[each.key].output_path
    source_code_hash = data.archive_file.this_lambda_zip[each.key].output_base64sha256
    timeout = each.value["timeout"]
}



