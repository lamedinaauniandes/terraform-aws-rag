module "buckets" {
  source = "./module_buckets"
  buckets_variable = {
    bucket1 = {                    ## name of object bucket
      name_bucket = "lam-rag-docs" ## name of aws buckect
    }
    bucket2 = {
      name_bucket = "lam-front-docs"
    }
  }
}


# module "api_rest" { 
#     source = "./module_api_rest"
#     resources =  { 
#         resourceA =  {
#             name_resource = "resourceA"
#             name_lambda = "lambdaA"
#         }
#         resourceB = { 
#             name_resource = "resourceB"
#             name_lambda = "lambdaB"
#         }
#     }
# }