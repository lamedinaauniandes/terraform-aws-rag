from sentence_transformers import SentenceTransformer
from langchain_openai import OpenAIEmbeddings


def create_embeddings(tokens,model,**kwargs): 
    """
    Generate embeddings whit hugginface, 
    """
    ### creating data for pinecone 
    model = SentenceTransformer(model,device='cpu')
    embeddings = list(map(lambda x: model.encode(x).tolist(),tokens))
    embddings_list = [(str(i),embeddings[i],{"text":tokens[i]}) for i in range(len(embeddings))]    

    return embddings_list,"create_embeddings"
    
def create_embeddings_openai(tokens,model,**kwargs): 
    """ 
    generate embeddings with open AI 
    args: 
     tokens: 
     model: 
     api_key: key of open AI token
     dimensions:
    Output: 
        list of tokens:
        name_function: 
    """
    print(f"""
        debug -> function embedding: 
        {kwargs.get("dimensions")}
        {tokens}
        {model}
     """)
    model  = OpenAIEmbeddings(
        model=model,
        api_key= kwargs.get("api_key"),
        dimensions=kwargs.get("dimensions")
    )
    # embeddings = list(map(lambda x: model.encode(x).tolist(),tokens))
    embeddings = model.embed_documents(tokens)
    embddings_list = [(str(i),embeddings[i],{"text":tokens[i]}) for i in range(len(embeddings))]    
    return embddings_list,"create_embeddings_openai"


if __name__=="__main__":
    create_embeddings_openai(
        tokens=["hola mundo"],
        model="text-embedding-3-small",
        api_key="ffff"
        )
