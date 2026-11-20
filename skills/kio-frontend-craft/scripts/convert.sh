#!/usr/bin/env bash
# ==============================================================================
# Script: convert.sh (PDF to HTML Master Converter)
# Purpose: Convert PDF files to pixel-perfect HTML using pdf2htmlEX or pdftohtml
# ==============================================================================

set -euo pipefail

IMAGE_NAME="pdf2htmlex/pdf2htmlex:0.18.8.rc2-master-20200820-ubuntu-20.04-x86_64"

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
Usage: $(basename "$0") <input.pdf> [output.html] [options]

Arguments:
  input.pdf            Đường dẫn file PDF cần chuyển đổi (bắt buộc)
  output.html          Đường dẫn hoặc tên file HTML đầu ra (mặc định: cùng thư mục file PDF)

Tùy chọn bổ sung (Options):
  --engine <auto|pdf2htmlex|poppler>
                       Chọn công cụ chuyển đổi (mặc định: auto)
                       - auto: Ưu tiên pdf2htmlEX (nếu có native/docker), fallback sang pdftohtml
                       - pdf2htmlex: Sử dụng pdf2htmlEX (Native hoặc Docker)
                       - poppler: Sử dụng pdftohtml (Poppler native, siêu nhẹ, không cần Docker)
  --fmt <jpg|png>      Định dạng ảnh nền nhúng base64 (mặc định: jpg để tối ưu dung lượng <10MB)
  --zoom <float>       Tỷ lệ phóng to (mặc định: 1.3)
  --split-pages        Tách từng trang thành các file HTML riêng biệt
  --embed-all          Nhúng toàn bộ CSS, font, hình ảnh dạng base64 data URLs (Single HTML)
  -h, --help           Hiển thị hướng dẫn này

Ví dụ:
  # Chuyển đổi tối ưu dung lượng siêu nhẹ (dưới 5MB - 10MB):
  $(basename "$0") document.pdf output.html --fmt jpg

  # Chuyển đổi giữ ảnh PNG lossless:
  $(basename "$0") document.pdf output.html --fmt png
EOF
}

if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

INPUT_FILE="$1"
shift

if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}[LỖI]${NC} File không tồn tại: $INPUT_FILE" >&2
    exit 1
fi

INPUT_ABS="$(realpath "$INPUT_FILE")"
INPUT_DIR="$(dirname "$INPUT_ABS")"
INPUT_BASE="$(basename "$INPUT_ABS")"
INPUT_STEM="${INPUT_BASE%.*}"

OUTPUT_ABS=""
if [[ $# -gt 0 ]] && [[ "$1" != --* ]]; then
    TARGET="$1"
    shift
    if [[ "$TARGET" = /* ]]; then
        OUTPUT_ABS="$TARGET"
    else
        OUTPUT_ABS="$(pwd)/$TARGET"
    fi
else
    OUTPUT_ABS="${INPUT_DIR}/${INPUT_STEM}.html"
fi

OUTPUT_DIR="$(dirname "$OUTPUT_ABS")"
OUTPUT_BASE="$(basename "$OUTPUT_ABS")"
mkdir -p "$OUTPUT_DIR"

# Options
ENGINE="auto"
FMT="jpg"
ZOOM=""
SPLIT_PAGES=0
EMBED_ALL=1
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --engine)
            ENGINE="$2"
            shift 2
            ;;
        --fmt)
            FMT="$2"
            shift 2
            ;;
        --zoom)
            ZOOM="$2"
            shift 2
            ;;
        --split-pages)
            SPLIT_PAGES=1
            shift
            ;;
        --embed-all)
            EMBED_ALL=1
            shift
            ;;
        *)
            EXTRA_ARGS+=("$1")
            shift
            ;;
    esac
done

echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}   🚀 PDF to HTML Converter (Pixel-Perfect)    ${NC}"
echo -e "${CYAN}===============================================${NC}"
echo -e "📄 File nguồn: ${YELLOW}${INPUT_ABS}${NC}"
echo -e "🌐 File đích:  ${GREEN}${OUTPUT_ABS}${NC}"
echo -e "🖼️  Định dạng ảnh: ${CYAN}${FMT^^}${NC} (Tối ưu dung lượng)"

# Detect available engines
HAS_NATIVE_PDF2HTMLEX=0
HAS_DOCKER=0
HAS_POPPLER=0

if command -v pdf2htmlEX >/dev/null 2>&1; then
    HAS_NATIVE_PDF2HTMLEX=1
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    HAS_DOCKER=1
fi

if command -v pdftohtml >/dev/null 2>&1; then
    HAS_POPPLER=1
fi

# Determine engine to run
SELECTED_ENGINE=""
if [[ "$ENGINE" == "pdf2htmlex" ]]; then
    if [[ $HAS_NATIVE_PDF2HTMLEX -eq 1 ]] || [[ $HAS_DOCKER -eq 1 ]]; then
        SELECTED_ENGINE="pdf2htmlex"
    else
        echo -e "${RED}[LỖI]${NC} Bạn yêu cầu engine pdf2htmlex nhưng không có pdf2htmlEX native lẫn Docker daemon!" >&2
        exit 1
    fi
elif [[ "$ENGINE" == "poppler" ]]; then
    if [[ $HAS_POPPLER -eq 1 ]]; then
        SELECTED_ENGINE="poppler"
    else
        echo -e "${RED}[LỖI]${NC} Không tìm thấy lệnh 'pdftohtml' (poppler-utils) trên hệ thống!" >&2
        exit 1
    fi
else
    # Auto selection
    if [[ $HAS_NATIVE_PDF2HTMLEX -eq 1 ]]; then
        SELECTED_ENGINE="pdf2htmlex"
    elif [[ $HAS_POPPLER -eq 1 ]]; then
        SELECTED_ENGINE="poppler"
    elif [[ $HAS_DOCKER -eq 1 ]]; then
        SELECTED_ENGINE="pdf2htmlex"
    else
        echo -e "${RED}[LỖI]${NC} Không tìm thấy bất kỳ công cụ nào (pdftohtml, pdf2htmlEX, Docker)!" >&2
        exit 1
    fi
fi

echo -e "⚙️  Engine:     ${BLUE}${SELECTED_ENGINE}${NC}"

if [[ "$SELECTED_ENGINE" == "pdf2htmlex" ]]; then
    if [[ $HAS_NATIVE_PDF2HTMLEX -eq 1 ]]; then
        echo -e "${GREEN}✓ Đang chạy pdf2htmlEX native...${NC}"
        CMD=(pdf2htmlEX)
        [[ -n "$ZOOM" ]] && CMD+=(--zoom "$ZOOM")
        [[ $SPLIT_PAGES -eq 1 ]] && CMD+=(--split-pages 1)
        if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
            CMD+=("${EXTRA_ARGS[@]}")
        fi
        CMD+=("$INPUT_ABS" "$OUTPUT_ABS")
        "${CMD[@]}"
    else
        echo -e "${YELLOW}✓ Đang chạy pdf2htmlEX qua Docker container...${NC}"
        CURRENT_UID="$(id -u)"
        CURRENT_GID="$(id -g)"
        DOCKER_ARGS=(
            docker run --rm
            --user "${CURRENT_UID}:${CURRENT_GID}"
            -v "${INPUT_DIR}:/in:ro"
            -v "${OUTPUT_DIR}:/out"
            -w "/out"
            "${IMAGE_NAME}"
            pdf2htmlEX
        )
        [[ -n "$ZOOM" ]] && DOCKER_ARGS+=(--zoom "$ZOOM")
        [[ $SPLIT_PAGES -eq 1 ]] && DOCKER_ARGS+=(--split-pages 1)
        if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
            DOCKER_ARGS+=("${EXTRA_ARGS[@]}")
        fi
        DOCKER_ARGS+=("/in/${INPUT_BASE}" "${OUTPUT_BASE}")
        "${DOCKER_ARGS[@]}"
    fi
elif [[ "$SELECTED_ENGINE" == "poppler" ]]; then
    echo -e "${GREEN}✓ Đang chạy pdftohtml (Poppler) tối ưu pixel-perfect...${NC}"
    POP_CMD=(pdftohtml -c -noframes)
    if [[ $SPLIT_PAGES -eq 0 ]]; then
        POP_CMD+=(-s)
    fi
    if [[ $EMBED_ALL -eq 1 ]]; then
        POP_CMD+=(-dataurls)
    fi
    if [[ -n "$FMT" ]]; then
        POP_CMD+=(-fmt "$FMT")
    fi
    if [[ -n "$ZOOM" ]]; then
        POP_CMD+=(-zoom "$ZOOM")
    else
        POP_CMD+=(-zoom 1.3)
    fi
    if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
        POP_CMD+=("${EXTRA_ARGS[@]}")
    fi
    POP_CMD+=("$INPUT_ABS" "$OUTPUT_ABS")
    "${POP_CMD[@]}"
fi

if [[ -f "$OUTPUT_ABS" ]]; then
    # Inject responsive viewer styles
    sed -i 's|</head>|<style type="text/css">body { margin: 0; padding: 24px 0; background: #232527 !important; display: flex; flex-direction: column; align-items: center; overflow-x: auto; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; } div[id^="page"] { box-shadow: 0 10px 35px rgba(0, 0, 0, 0.6); margin-bottom: 32px; background: #ffffff; border-radius: 6px; overflow: hidden; }</style></head>|' "$OUTPUT_ABS"

    FILE_SIZE="$(du -h "$OUTPUT_ABS" | cut -f1)"
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}🎉 Chuyển đổi thành công!${NC}"
    echo -e "📁 File kết quả:  ${GREEN}${OUTPUT_ABS}${NC}"
    echo -e "📊 Dung lượng:     ${CYAN}${FILE_SIZE}${NC}"
    echo -e "${GREEN}===============================================${NC}"
else
    echo -e "${RED}[LỖI]${NC} Không tìm thấy file đầu ra $OUTPUT_ABS sau khi chạy." >&2
    exit 1
fi
