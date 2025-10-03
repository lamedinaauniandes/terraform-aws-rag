data "archive_file" "lambda_zip" {
    for_each = var.lambdas
    type = "zip"
    source_file = each.value["source_file"]
    output_path = each.value["output_path"]    
}