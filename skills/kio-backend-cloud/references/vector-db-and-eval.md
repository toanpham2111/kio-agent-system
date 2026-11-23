# Vector Databases & Evaluation Metrics

## 1. Vector Distance Metric Guide
- **Cosine Distance (`<=>`)**: Default for normalized embeddings (OpenAI, Voyage AI, Cohere). Measures angular difference regardless of vector magnitude.
- **L2 Distance / Euclidean (`<->`)**: For unnormalized dense features.
- **Inner Product (`<#>`)**: Fastest if embeddings are guaranteed unit length. pgvector returns the **negative** inner product, so `ORDER BY embedding <#> $1` (ascending) is correct.

## 2. Automated Evaluation with RAGAS Framework
```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision, context_recall
from datasets import Dataset

dataset = Dataset.from_dict({
    "question": ["What is Kio's mobile architecture?"],
    "contexts": [["Kio uses Expo Router and NativeWind with Hermes engine..."]],
    "answer": ["Kio's mobile stack is built on Expo Router and NativeWind."],
    "ground_truth": ["Kio relies on Expo Router and NativeWind for cross-platform apps."]
})

results = evaluate(
    dataset,
    metrics=[faithfulness, answer_relevancy, context_precision, context_recall]
)
print(results)
```

> RAGAS changes its API between versions (column names such as `question/answer/contexts/ground_truth` vs `user_input/response/retrieved_contexts/reference`). Pin the version and follow its docs for that release.

## 3. Index choice (pgvector)
| Index | Build | Query | Use when |
|---|---|---|---|
| None (exact) | – | Slow beyond ~100k rows | Small tables, ground-truth for recall checks |
| **HNSW** | Slower, more memory | Fast, high recall | Default for most apps; works on an empty table |
| IVFFlat | Fast | Needs `lists`/`probes` tuning | Very large, mostly static data; build after loading |

```sql
CREATE INDEX ON chunks USING hnsw (embedding vector_cosine_ops) WITH (m = 16, ef_construction = 64);
SET hnsw.ef_search = 100;   -- per session/transaction: higher = better recall, slower
```
- The operator class must match the query operator (`vector_cosine_ops` ↔ `<=>`, `vector_l2_ops` ↔ `<->`, `vector_ip_ops` ↔ `<#>`), or the index is ignored.
- Filters + ANN: with selective `WHERE tenant_id = ...`, HNSW may return too few rows; use pgvector ≥ 0.8 iterative scans (`SET hnsw.iterative_scan = relaxed_order`) or partition per tenant.
- Dimensions: `vector` supports up to 2 000 dims for indexing; use `halfvec` for larger or to halve memory.

## 4. When to leave Postgres
Stay on pgvector until you have tens of millions of vectors, very high QPS, or need features like built-in hybrid scoring across shards. Then consider Qdrant, Weaviate, Milvus, or a managed service — keep the same chunk/metadata schema so migration is a re-index, not a redesign.

## 5. Building an evaluation set
1. Collect 50–200 real questions (logs, support tickets), not ones you invent from the docs.
2. For each: the expected answer and the **IDs of the chunks** that contain it.
3. Include hard cases: multi-hop, out-of-scope ("we don't sell that"), ambiguous, outdated info.

## 6. Metrics
| Layer | Metric | Meaning |
|---|---|---|
| Retrieval | recall@k | Share of questions whose gold chunk is in the top k |
| Retrieval | MRR / nDCG | How high the gold chunk ranks |
| Generation | faithfulness | Answer claims are supported by retrieved context |
| Generation | answer relevancy / correctness | Answers the question, matches the reference |
| System | latency p95, cost per query | Production budget |

```python
def recall_at_k(results: dict[str, list[str]], gold: dict[str, set[str]], k: int = 5) -> float:
    hits = sum(1 for q, ids in results.items() if gold[q] & set(ids[:k]))
    return hits / len(results)
```
Run the eval in CI on every change to chunking, embedding model, retrieval or prompts, and fail the build on a regression beyond a set threshold.
