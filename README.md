# terraform-aws-rag
This repository deploys a serverless API on AWS with Terraform, implementing the Retrieval-Augmented Generation (RAG) pattern with support for vector databases.

Infrastructure-as-Code portfolio project for deploying a serverless API on AWS using Terraform, implementing the Retrieval-Augmented Generation (RAG) pattern.

The RAG module is designed to support multiple vector database backends. At the beginning, the implementation is adapted for Pinecone, but additional modules (e.g., Chroma, FAISS, Weaviate) will be added to extend its use cases.

The architecture is modular and configurable: by adjusting variables, you can adapt the deployment to different vector databases and application needs. Each Terraform module provisions the required infrastructure and deploys the API services automatically, making the solution flexible, reusable, and extensible.

## Network design
For simplicity and cost-efficiency, this project deploys Lambda and API Gateway in a **public context (no VPC)**.
This enables fast deployment and minimal setup for educational and prototyping purposes.
A VPC-based version (with private subnets and NAT) can be easily added if required for production environments.

## Architecture
![Architecture Diagram](docs/terraform-aws-rag-architecture.png)

The solution is built as a **serverless API** on AWS, provisioned with **Terraform**.  
Incoming requests are routed through **API Gateway** to **Lambda functions**, which orchestrate three main modules:  

- **IAC** This Infrastructure as Code module is designed to easily deploy a REST API infrastructure on AWS using Terraform, Lambda functions, and the API Gateway service.. 

- **pinecone_rag Module** → Connects to a vector database service (initially Pinecone, later extendable to Chroma, FAISS, etc.), for see how use the implementation see run_rag.ipynb. For this modules at begining I use the module langchain_openai the class ChatOpenAI 
for extend the queries.

- **lambda module** -> In this module, you can see how to build the Lambdas. With the appropriate configurations, you can deploy all the Lambdas using the IAC module.

This modular design makes it easy to plug in different backends for retrievers and generators without changing the overall infrastructure.

## Future Work
- Add support for additional vector databases: Chroma, FAISS, Weaviate.  
- Extend LLM module with Hugging Face Transformers and AWS Bedrock.  
- Implement CI/CD pipelines for automated deployments.  
- Add monitoring and logging with CloudWatch.  
