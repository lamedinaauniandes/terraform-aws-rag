resource "aws_s3_bucket" "this_bucket" { 
    for_each = var.buckets_variable 
    bucket = each.value["name_bucket"]
}

