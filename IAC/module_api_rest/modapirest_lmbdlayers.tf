data "archive_file" "this_layer_zip" { 
    type = "zip"
    for_each = var.lambda_layers 
    source_dir = each.value["source_dir"]
    output_path = each.value["output_path"]
}


resource "aws_lambda_layer_version" "this_lambda_layer" { 
    for_each = var.lambda_layers
    layer_name = each.value["name_layer"]
    filename  = data.archive_file.this_layer_zip[each.key].output_path
    compatible_runtimes = ["python3.12"]
    description = each.value["description"]
}

