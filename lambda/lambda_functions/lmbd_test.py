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
     
    secret_name = os.environ["secret_name_pinecone"]
    region_name = os.environ["region_name"]

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret_string = get_secret_value_response['SecretString']
        secret_dict = json.loads(secret_string)
        token_pinecone = secret_dict['token_pinecone']

    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return {
                "statusCode": 500,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"message": "Error retrieving secret"})
            }

    pc = Pinecone(api_key=token_pinecone)
    print(pc.list_indexes())
    
    return {
        "statusCode":200,
        "headers": {"Content-Type":"application/json"},
        "body": json.dumps({"message":"Hi world!!! (RAG api), version pandas"})
    }
