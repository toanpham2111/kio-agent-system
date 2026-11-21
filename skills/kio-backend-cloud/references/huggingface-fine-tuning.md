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

# Merge into the full-precision base (bf16), not the 4-bit model used for training
base_model = AutoModelForCausalLM.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct", torch_dtype="bfloat16")
model = PeftModel.from_pretrained(base_model, "./kio-model-output")
merged_model = model.merge_and_unload()

merged_model.save_pretrained("./kio-llama3-merged")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
tokenizer.save_pretrained("./kio-llama3-merged")
```

## 3. Decide first: do you need fine-tuning?
| Problem | Better first move |
|---|---|
| Model lacks **knowledge** (docs, policies, prices) | RAG (`production-rag-pipelines.md`) — fine-tuning does not reliably add facts |
| Output **format/style** is inconsistent | Prompting + few-shot + structured output |
| Narrow, repetitive task at high volume, latency/cost bound | Fine-tune a small model (this file) |
| Need a new behaviour you can show in ≥ 500–1 000 high-quality examples | Fine-tune |

Always build the **evaluation set before training** (held-out, never seen in training) and record the base model's score on it.

## 4. QLoRA training with TRL
```python
import torch
from datasets import load_dataset
from peft import LoraConfig
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from trl import SFTConfig, SFTTrainer

model_id = "meta-llama/Meta-Llama-3-8B-Instruct"
bnb = BitsAndBytesConfig(load_in_4bit=True, bnb_4bit_quant_type="nf4",
                         bnb_4bit_compute_dtype=torch.bfloat16, bnb_4bit_use_double_quant=True)
model = AutoModelForCausalLM.from_pretrained(model_id, quantization_config=bnb, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(model_id)

data = load_dataset("json", data_files={"train": "train.jsonl", "eval": "eval.jsonl"})
peft_config = LoraConfig(r=16, lora_alpha=32, lora_dropout=0.05, bias="none",
                         target_modules="all-linear", task_type="CAUSAL_LM")
args = SFTConfig(
    output_dir="./kio-model-output",
    num_train_epochs=2,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=8,        # effective batch 16
    learning_rate=2e-4,
    lr_scheduler_type="cosine",
    warmup_ratio=0.03,
    bf16=True,
    gradient_checkpointing=True,
    logging_steps=10,
    eval_strategy="steps",
    eval_steps=100,
    save_steps=100,
)
trainer = SFTTrainer(model=model, args=args, train_dataset=data["train"],
                     eval_dataset=data["eval"], peft_config=peft_config, processing_class=tokenizer)
trainer.train()
trainer.save_model()  # saves the adapter only
```
TRL renames arguments between releases (e.g. `tokenizer` → `processing_class`, `max_seq_length` → `max_length`); pin `trl`, `transformers`, `peft`, `bitsandbytes` versions in `requirements.txt` and check the release notes when upgrading.

## 5. Data quality rules
- Use the model's **chat template** (`tokenizer.apply_chat_template`); the `messages` format above lets TRL do it.
- Deduplicate, strip PII/secrets, and balance task types; 1 000 clean examples beat 50 000 noisy ones.
- Keep a fixed system prompt identical between training and serving.
- Train on assistant turns only (completion-only loss) when prompts are long and repetitive.

## 6. Signals while training
- Eval loss rising while train loss falls → overfitting: fewer epochs, more data, lower `r`.
- Loss stuck → learning rate too low, or chat template / labels wrong (inspect a decoded batch).
- Compare base vs fine-tuned on the held-out eval set and on a **general** sanity set to catch regressions.

## 7. Serving
- vLLM can serve the base model plus LoRA adapters (`--enable-lora --lora-modules kio=./kio-model-output`) without merging.
- Merge (§2) for llama.cpp/Ollama, then convert to GGUF and quantise (`Q4_K_M` is a common balance).
- Check the base model's licence before commercial use or redistribution of merged weights.
