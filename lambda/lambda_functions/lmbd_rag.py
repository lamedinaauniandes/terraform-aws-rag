import os 
import json
import boto3
from pinecone import Pinecone,ServerlessSpec
from langchain_openai import ChatOpenAI,OpenAIEmbeddings 
from langchain_core.prompts import(
    ChatPromptTemplate, 
    PromptTemplate, 
    SystemMessagePromptTemplate, 
    AIMessagePromptTemplate, 
    HumanMessagePromptTemplate,
)
from typing import (
    Callable, 
    List,
    Dict,
)
import rag_pinecone
from rag_pinecone import lyr_rag_pinecone
 
def handler(event,context):
    method = event.get("httpMethod")

    if method == "GET":
        ## only one method without memory. 
        query = event.get("queryStringParameters") or {}
        query_r = query.get("query")
        
        ######
        ## initializing secrets 
        #####
        secret_name_pinecone = os.environ["secret_name_pinecone"]
        secret_name_openai = os.environ["secret_name_openai"]
        region_name = os.environ["region_name"]

        session = boto3.session.Session()
        client = session.client(
            service_name = "secretsmanager",
            region_name = region_name, 
        )

        try: 
            get_secret_value_pinecone = client.get_secret_value(
                SecretId = secret_name_pinecone,
            )
            get_secret_value_openai = client.get_secret_value( 
                SecretId = secret_name_openai,
            )

            secret_string_pinecone = get_secret_value_pinecone["SecretString"]
            secret_dict_pinecone = json.loads(secret_string_pinecone)
            token_pinecone = secret_dict_pinecone["token_pinecone"]

            secret_string_openai = get_secret_value_openai["SecretString"]
            secret_dict_openai = json.loads(secret_string_openai)
            token_openai = secret_dict_openai["terraform_aws_rag/apenai_token"]

        except Exception as e: 
            return { 
                "statusCode":500, 
                "headers": {"Content-Type":"application/json"}, 
                "body": json.dumps({"message":f"Error retrieving secret: {e}"})
            }

        #######
        ## END
        #######

        #########
        ## APPLYING RAG LIBRARY
        #########
        try: 
            rag_q = lyr_rag_pinecone.Rag_queries( pinecone_key = token_pinecone , openai_key=token_openai)
        except Exception as e: 
            return { 
                "statusCode":500,
                "headers": {"Content-Type":"application/json"}, 
                "body": json.dumps({"message":f"Error module rag , {e}"})
            }


        #########
        ## END
        #########


    return { 
        "statusCode":200, 
        "headers": {"Content-Type":"application/json"}, 
        "body": json.dumps({
            "message": "GET /RAG", 
            "answer":"", 
        })
    }

