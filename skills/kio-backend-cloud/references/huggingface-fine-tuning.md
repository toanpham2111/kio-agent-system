# Hugging Face QLoRA & SFTTrainer Guide

## 1. Preparing Instruction Tuning Dataset (JSONL)
Format data with standard user/assistant chat roles:
```json
{"messages": [{"role": "system", "content": "You are Kio, an expert coding assistant."}, {"role": "user", "content": "Optimize this SQL query."}, {"role": "assistant", "content": "Here is the optimized query with an index plan..."}]}
```

## 2. Merging LoRA Adapters into Standalone Base Model
To export for Ollama, vLLM, or GGUF deployment:
```python
from peft import PeftModel
from transformers import AutoModelForCausalLM, AutoTokenizer

base_model = AutoModelForCausalLM.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
model = PeftModel.from_pretrained(base_model, "./kio-model-output")
merged_model = model.merge_and_unload()

merged_model.save_pretrained("./kio-llama3-merged")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
tokenizer.save_pretrained("./kio-llama3-merged")
```
