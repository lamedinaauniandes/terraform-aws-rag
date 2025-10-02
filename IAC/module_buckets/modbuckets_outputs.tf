output "modbuckets_outputs_bucket_one" { 
    value = aws_s3_bucket.this_bucket["bucket1"].bucket
}


