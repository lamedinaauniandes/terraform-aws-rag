import os 
import json
import torch
from pathlib import Path
import embedding_functions
from embedding_functions import *
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv
from pinecone import Pinecone,ServerlessSpec
from langchain_openai import ChatOpenAI,OpenAIEmbeddings
from pypdf import PdfReader
from typing import (
    Callable, 
    List,
    Dict,
)

from langchain.prompts import (
    ChatPromptTemplate,
    PromptTemplate,
    SystemMessagePromptTemplate,
    AIMessagePromptTemplate,
    HumanMessagePromptTemplate
)


BASE_DIR = Path(os.getcwd()).parent
PATH_ENV = os.path.join(BASE_DIR,".env")
PATH_MODULE = os.path.join(BASE_DIR,"1_codes_rag_pinecone")
PATH_CONFIG = os.path.join(PATH_MODULE,"config.json")

load_dotenv(override=True,dotenv_path=PATH_ENV)
f_config = open(PATH_CONFIG,'r')
config = json.load(f_config)

class Rag_tools: 

    def __init__(self,name_index=None):
        self.name_index = None
        self.namespace = None
        self.idx = None

        self.pinecone_key = os.getenv("pinecone_token")
        self.openai_key = os.getenv("OPENAI_API_KEY")
        
        self.pc = Pinecone(api_key = self.pinecone_key)

        self.path_indexes_json = os.path.join(PATH_MODULE,'indexes.json')
        self._read_indexes_file()
        return
    
    def _read_indexes_file(self): 
        f = open(self.path_indexes_json,'r')
        self.indexes_object = json.load(f)
        return    

    def get_list_indexes(self): 
        return self.pc.list_indexes()
    
    def get_list_namespaces(self,name_index):
        idx = self.pc.Index(name_index)
        return [namespace for namespace in idx.list_namespaces()]

    def set_index(self,name_index):
        self._read_indexes_file()
        assert name_index in self.indexes_object.keys(),f"{name_index} index doesn't exist, please create one"
        self.name_index = name_index
        self.idx = self.pc.Index(name_index)

    def set_namespace(self,namespace):
        assert self.name_index, "please set index"

        self.namespace = namespace
        return self.namespace
    
    def set_system_template(self,system_template): 
        self.system_template = system_template
        return self.system_template 

    def create_index(self,name_index,name_model,dimension): 

        indexes = self.pc.list_indexes()
        name_indexes = [index["name"] for index in indexes]
        assert name_index not in name_indexes, f"{name_index} exist"
 
        self.indexes_object[name_index] = {}
        self.indexes_object[name_index]["model"] = name_model
        self.indexes_object[name_index]["dimension"] = dimension
        self.indexes_object[name_index]["namespaces"] = []

        self.pc.create_index(
            name_index,
            dimension =dimension,
            metric="dotproduct", 
            spec=ServerlessSpec(cloud="aws",region="us-east-1")   ## free version
            )
        
        with open(self.path_indexes_json,"w",encoding="utf-8") as file: 
            json.dump(self.indexes_object,file,indent=4)

        return True
    
    def insert_embeddings(
            self, 
            name_tokens:str,         ### TOKEN_THESIS 
            name_tokenization: str,  ### FOR EACH TOKES EXIST A TOKENIZATION 
            embeding_function: Callable[[List[str]], List[float]],
    ): 
        """
        Create namespace with the embeddings for pinecone, with all-MiniLM-L6-v2 transformer
        Only search tokens for the thesis document
        """    
        assert self.name_index, "please set index"
        assert self.namespace, "please set namespace"
        self._read_indexes_file()

        index_obj = self.indexes_object[self.name_index]

        assert name_tokens in config["PATHS"], f"doesn't exist {name_tokens} in config"

        path_tokens = os.path.join(BASE_DIR,config["PATHS"][name_tokens])
        file_tokens = open(path_tokens,"r",encoding="utf-8")
        tokens = json.load(file_tokens)
        tokens = tokens[name_tokenization]["values"]

        embddings_list,name_embeding_function = embeding_function(
            tokens=tokens,
            model=index_obj["model"],
            api_key=self.openai_key,
            dimensions = index_obj["dimension"]
        )

        self.idx.upsert(embddings_list,namespace=self.namespace)

        if name_embeding_function not in index_obj.keys():
            index_obj["name_embd_function"] = name_embeding_function

        if self.namespace not in index_obj["namespaces"]: 
            index_obj["namespaces"].append(self.namespace)
            
        self.indexes_object[self.name_index] = index_obj

        with open(self.path_indexes_json,"w",encoding="utf-8") as file: 
            json.dump(self.indexes_object,file,indent=4)
        
        return True

class Rag_queries: 
    
    def __init__(self):
        self.name_index = None
        self.namespace = None
        self.client = None
        self.idx = None

        pinecone_key = os.getenv("pinecone_token")
        self.openai_key = os.getenv("OPENAI_API_KEY")
        
        self.pc = Pinecone(api_key = pinecone_key)

        self.path_indexes_json = os.path.join(PATH_MODULE,'indexes.json')
        self._read_indexes_file()
        return
    
    def _read_indexes_file(self): 
        f = open(self.path_indexes_json,'r')
        self.indexes_object = json.load(f)
        return    

    def get_list_indexes(self): 
        return self.pc.list_indexes()
    
    def get_list_namespaces(self,name_index):
        idx = self.pc.Index(name_index)
        return [namespace for namespace in idx.list_namespaces()]
    
    def set_client(self,model="gpt-4o-mini"):
        # at this moment I fix to ChatOpenAI later I'll do more flexible
        self.client = ChatOpenAI(
            model = model,
            api_key = self.openai_key
        ) 
        return self.client

    def set_index(self,name_index):
        self._read_indexes_file()
        assert name_index in self.indexes_object.keys(),f"{name_index} index doesn't exist, please create one"
        self.name_index = name_index
        self.idx = self.pc.Index(name_index)

    def set_namespace(self,namespace):
        assert self.name_index, "please set index"

        self.namespace = namespace
        return self.namespace
    
    def set_system_template(self,system_template): 
        self.system_template = system_template
        return self.system_template 

    def _aug_query(self,system_template:str,query:str): 
        assert self.client, f"set client is necessary"
        human_template = "{query}"
        system_message_prompt = SystemMessagePromptTemplate.from_template(system_template)
        human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
        chat_prompt = ChatPromptTemplate.from_messages([system_message_prompt,human_message_prompt])
        chain = chat_prompt|self.client
        self.hipotetycall_answer = chain.invoke({"query":query})
        self.augmented_query = f"{query} {self.hipotetycall_answer.content}"
        return self.augmented_query
    
    def search_query(self,query:str): 
        assert self.idx, "please, set index"
        assert self.namespace, "please set namespace"
        assert self.system_template, "please set system template"

        name_model = self.indexes_object[self.name_index]["model"]
        name_function_embedding = self.indexes_object[self.name_index]["name_embd_function"]
        dimensions = self.indexes_object[self.name_index]["dimension"]
        
        re_aug_query = self._aug_query(self.system_template,query)

        function_embedding = getattr(embedding_functions,name_function_embedding)
        embeddings_list,_ = function_embedding(
            tokens = [re_aug_query], 
            model = name_model,
            api_key= self.openai_key,
            dimensions = dimensions
        )
        _,embeding_vector,_ = embeddings_list[0]
        re = self.idx.query(
            vector = embeding_vector , 
            top_k=10, 
            namespace = self.namespace, 
            include_metadata = True, 
            include_values = True
        )

        return re 
        
    