import json
import pandas as pd
import requests

def handler(event,context):
     
    return {
        "statusCode":200,
        "headers": {"Content-Type":"application/json"},
        "body": json.dumps({"message":"Hi world!!! (RAG api), version pandas"})
    }











