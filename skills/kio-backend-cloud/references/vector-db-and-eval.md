# Vector Databases & Evaluation Metrics

## 1. Vector Distance Metric Guide
- **Cosine Distance (`<=>`)**: Default for normalized embeddings (OpenAI, Voyage AI, Cohere). Measures angular difference regardless of vector magnitude.
- **L2 Distance / Euclidean (`<->`)**: For unnormalized dense features.
- **Inner Product (`<#>`)**: Fastest if embeddings are guaranteed unit length.

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
