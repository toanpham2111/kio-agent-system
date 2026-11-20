#!/usr/bin/env python3
import os
import re

REPLACEMENTS = [
    # Authors
    ("author: Kio System", "author: Kio System"),
    ("author: Kio System", "author: Kio System"),
    ("Kio Core Team", "Kio Core Team"),
    ("Kio System", "Kio System"),
    ("Kio Core Team", "Kio Core Team"),
    
    # Alibaba -> Kio Enterprise
    ("Kio 5-Layer Quality Standards", "Kio 5-Layer Quality Standards"),
    ("Kio 5-Layer Standards", "Kio 5-Layer Standards"),
    ("Kio 5-Layer Standards", "Kio 5-Layer Standards"),
    ("Kio's 5-layer enterprise review standard", "Kio's 5-layer enterprise review standard"),
    ("Kio's 5 critical engineering layers", "Kio's 5 critical engineering layers"),
    ("Kio `ocr` CLI", "Kio `ocr` CLI"),
    ("Kio `ocr`", "Kio `ocr`"),
    ("kiểm tra 5 lớp chất lượng Kio Enterprise", "kiểm tra 5 lớp chất lượng Kio Enterprise"),
    ("5 lớp chất lượng Kio Enterprise", "5 lớp chất lượng Kio Enterprise"),

    # Kio Growth Engine -> Kio Growth System
    ("53 specialized Kio growth & CRO frameworks", "53 specialized Kio growth & CRO frameworks"),
    ("hệ sinh thái Kio Growth Engineering", "hệ sinh thái Kio Growth Engineering"),
    ("Kio System / Toan Pham", "Kio System / Toan Pham"),
    ("Kio Growth Engine", "Kio Growth Engine"),

    # Kio SEO Engine -> Kio SEO
    ("Kio System / Toan Pham", "Kio System / Toan Pham"),
    ("Kio SEO Engine", "Kio SEO Engine"),

    # Kio Web Perf Engine reference -> Kio Web Perf
    ("Kio Web Perf Engine", "Kio Web Perf Engine"),
    ("Kio Web Perf Engineormance", "Kio Web Performance"),

    # Kio Spec-Kit -> Kio Spec-Kit
    ("powered by Kio SDD Framework", "powered by Kio SDD Framework"),
    ("chuẩn Kio SDD Framework", "chuẩn Kio SDD Framework"),
    ("Kio Spec-Kit", "Kio Spec-Kit"),
]

TARGET_DIRS = ["skills", "agents", "rules", "memory", "scripts"]
TARGET_FILES = ["README.md", "README.en.md", "KNOWLEDGE_BASE.md", "KNOWLEDGE_BASE.en.md", "so_do_kio.html"]

workspace = "/home/toan/my-agent-skills"

modified_count = 0

def process_file(file_path):
    global modified_count
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception as e:
        return

    original = content
    for pattern, replacement in REPLACEMENTS:
        content = content.replace(pattern, replacement)

    if content != original:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        modified_count += 1
        print(f"Branded: {os.path.relpath(file_path, workspace)}")

# Process specific files
for tf in TARGET_FILES:
    fp = os.path.join(workspace, tf)
    if os.path.isfile(fp):
        process_file(fp)

# Process target dirs
for td in TARGET_DIRS:
    dir_path = os.path.join(workspace, td)
    if os.path.isdir(dir_path):
        for root, dirs, files in os.walk(dir_path):
            for file in files:
                if file.endswith((".md", ".html", ".sh", ".py", ".json", ".yaml", ".yml")):
                    process_file(os.path.join(root, file))

print(f"\nTotal files updated with 100% Pure Kio Branding: {modified_count}")
