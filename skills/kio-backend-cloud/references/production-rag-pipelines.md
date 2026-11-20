# Production RAG & Re-ranking Architecture

## 1. Reciprocal Rank Fusion (RRF) for Hybrid Search
Combine sparse (BM25) and dense (Vector) rankings using RRF:
```python
def reciprocal_rank_fusion(dense_ranks, sparse_ranks, k=60):
    rrf_score = {}
    for rank, doc_id in enumerate(dense_ranks):
        rrf_score[doc_id] = rrf_score.get(doc_id, 0) + 1.0 / (k + rank + 1)
    for rank, doc_id in enumerate(sparse_ranks):
        rrf_score[doc_id] = rrf_score.get(doc_id, 0) + 1.0 / (k + rank + 1)
    return sorted(rrf_score.items(), key=lambda x: x[1], reverse=True)
```

## 2. Cross-Encoder Re-Ranking Pipeline
```python
from sentence_transformers import CrossEncoder

reranker = CrossEncoder('BAAI/bge-reranker-large')

query = "How to configure zero downtime deployment in Terraform?"
candidates = ["Doc 1 text...", "Doc 2 text...", "Doc 3 text..."]

pairs = [[query, doc] for doc in candidates]
scores = reranker.predict(pairs)

# Sort candidates by descending relevance score
ranked_docs = [doc for _, doc in sorted(zip(scores, candidates), reverse=True)]
```
