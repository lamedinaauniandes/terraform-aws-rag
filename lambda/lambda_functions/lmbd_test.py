import json
import boto3
import os
from pinecone import Pinecone, ServerlessSpec
from langchain_openai import ChatOpenAI,OpenAIEmbeddings 
from langchain_core.prompts import(
    ChatPromptTemplate, 
    PromptTemplate, 
    SystemMessagePromptTemplate, 
    AIMessagePromptTemplate, 
    HumanMessagePromptTemplate,
)
import json


def handler(event,context):
    method = event.get("httpMethod")

    if method == "GET": 
        query = event.get("queryStringParameters") or {}
        query_r = query.get("query")
        
        ##########
        ## initializing secrets
        ##########
        secret_name_pinecone = os.environ["secret_name_pinecone"]
        secret_name_openai = os.environ["secret_name_openai"]
        region_name = os.environ["region_name"]

        session = boto3.session.Session()
        client = session.client( 
            service_name='secretsmanager', 
            region_name=region_name
        )

        try: 
            secret_value_pinecone = client.get_secret_value(
                SecretId=secret_name_pinecone
            )
            secret_value_openai = client.get_secret_value(
                SecretId=secret_name_openai, 
            )

            secret_string_pinecone = secret_value_pinecone["SecretString"]
            secret_dict_pinecone = json.loads(secret_string_pinecone)
            token_pinecone = secret_dict_pinecone["token_pinecone"]

            secret_string_openai = secret_value_openai["SecretString"]
            secret_dict_openai = json.loads(secret_string_openai)
            token_openai = secret_dict_openai["terraform_aws_rag/apenai_token"]
            
            debug = "debug_final"
            
        except Exception as e: 
            print(f"Error retrieving secret: {e}")
            return {
                "statusCode":500, 
                "headers":{"Content-Type": "application/json"},
                "body": json.dumps({"message":f"Error retrieving secret: {e}, {debug}"})
            }
        ########
        ## END GETTING TOKENS KEYS
        ########

        ########
        ## REVIEWING CONNECTIONS
        ######## 
        try: 
            debug = "debug 1"
            pc_db = Pinecone(api_key = token_pinecone)
            client_llm = ChatOpenAI(
                model = "gpt-4o-mini", 
                api_key= token_openai, 
            ) 

            human_template = "{query}"
            human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
            chat_prompt = ChatPromptTemplate.from_messages([human_message_prompt])
            chain = chat_prompt|client_llm

            answer = chain.invoke({"query":query})


            debug = "debug final, connection apis"
        except Exception as e: 
            return {
                "statusCode":500, 
                "headers": {"Content-Type":"application/json"}, 
                "body": json.dumps({"message":f"error conection apis: {e}, {debug}"})
            }


        ########
        ## EN REVIEWING CONNECTIONS
        ########

        return { 
            "statusCode":200, 
            "headers": {"Content-Type":"application/json"},
            "body":json.dumps({
                "message":"GET /test",
                "answer":answer.content,
            }),
        }
    
    elif method == "POST":
        body = json.loads(event.get("body") or "{}")

        return  {
            "statusCode":201, 
            "body":json.dumps({"action":"POST","data":body})
        }    
    return {
        "statusCode":405, 
        "body": json.dumps({"message":"Method not allowed"})
    }
