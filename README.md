# terraform-aws-rag
This repository deploys a serverless API on AWS with Terraform, implementing the Retrieval-Augmented Generation (RAG) pattern with support for vector databases.


Infrastructure-as-Code portfolio project for deploying a serverless API on AWS using Terraform, implementing the Retrieval-Augmented Generation (RAG) pattern.

The RAG module is designed to support multiple vector database backends. At the beginning, the implementation is adapted for Pinecone, but additional modules (e.g., Chroma, FAISS, Weaviate) will be added to extend its use cases.

The architecture is modular and configurable: by adjusting variables, you can adapt the deployment to different vector databases and application needs. Each Terraform module provisions the required infrastructure and deploys the API services automatically, making the solution flexible, reusable, and extensible.

------- ARCHICTECTURE ------
## Architecture
![Architecture Diagram](docs/terraform-aws-rag-architecture.png)
