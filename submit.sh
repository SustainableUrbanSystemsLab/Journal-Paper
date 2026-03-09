#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$REPO_ROOT/sub_1"
BUILD_DIR="$REPO_ROOT/build"
PDF_DIR="$REPO_ROOT/dist/pdf"
EXPORT_DIR="$REPO_ROOT/dist/export"

TARGET="${1:-all}"

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

strip_latex_text() {
  perl -0pe '
    s/%.*$//mg;
    s/\\[a-zA-Z@]+(?:\[[^][]*\])?(?:\{[^{}]*\})?/ /g;
    s/[{}]/ /g;
    s/\s+/ /g;
  ' "$1"
}

graphical_abstract_asset() {
  local extension
  for extension in pdf png jpg jpeg; do
    if [[ -f "$SOURCE_DIR/graphical_abstract.$extension" ]]; then
      printf '%s\n' "graphical_abstract.$extension"
      return 0
    fi
  done
  return 1
}

validate_placeholders() {
  if rg -n '\b(TITLE|HIGHLIGHT|KEYWORD|Author2)\b|example-image' "$SOURCE_DIR"/*.tex "$SOURCE_DIR"/*.bib >/dev/null; then
    die "Submission source still contains placeholder tokens."
  fi
}

validate_todos() {
  if rg -n '\\todo|\\todoo|\\rewrite' "$SOURCE_DIR"/*.tex >/dev/null; then
    die "Submission source still contains draft todo commands."
  fi
}

validate_abstract() {
  local abstract_words
  abstract_words="$(strip_latex_text "$SOURCE_DIR/abstract.tex" | wc -w | tr -d ' ')"
  if (( abstract_words > 250 )); then
    die "Abstract exceeds the 250 word limit ($abstract_words words)."
  fi
}

validate_keywords() {
  local keyword_count
  keyword_count="$(
    perl -0ne '
      s/%.*$//mg;
      s/\n/ /g;
      @items = grep { /\S/ } map { s/^\s+|\s+$//gr } split(/\\sep/, $_);
      print scalar(@items);
    ' "$SOURCE_DIR/keywords.tex"
  )"
  if (( keyword_count < 1 || keyword_count > 7 )); then
    die "Keyword count must be between 1 and 7 (found $keyword_count)."
  fi
}

validate_highlights() {
  local count=0
  local line
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*\\item[[:space:]]+(.+)$ ]] || continue
    local text="${BASH_REMATCH[1]}"
    text="$(printf '%s\n' "$text" | perl -0pe 's/\\[a-zA-Z@]+(?:\[[^][]*\])?(?:\{[^{}]*\})?/ /g; s/[{}]/ /g; s/\s+/ /g; s/^ //; s/ $//;')"
    local length=${#text}
    ((count += 1))
    if (( length > 85 )); then
      die "Highlight $count exceeds 85 characters ($length characters)."
    fi
  done < "$SOURCE_DIR/highlights_content.tex"

  if (( count < 3 || count > 5 )); then
    die "Highlight count must be between 3 and 5 (found $count)."
  fi
}

validate_bibliography() {
  rg -q '^@' "$SOURCE_DIR/bib.bib" || die "Bibliography database is empty."
}

validate_citations() {
  if ! rg -q '\\cite[a-zA-Z]*\{' "$SOURCE_DIR/paper.tex" "$SOURCE_DIR/content.tex" "$SOURCE_DIR/abstract.tex"; then
    die "Manuscript source must contain at least one citation command."
  fi
}

validate_source() {
  require_command latexmk
  require_command pdflatex
  require_command bibtex
  require_command rg
  require_command perl

  validate_placeholders
  validate_todos
  validate_abstract
  validate_keywords
  validate_highlights
  validate_bibliography
  validate_citations
}

compile_latex() {
  local tex_file="$1"
  local build_name="$2"
  local output_name="$3"
  local build_path="$BUILD_DIR/$build_name"

  mkdir -p "$build_path" "$PDF_DIR"
  (
    cd "$SOURCE_DIR"
    latexmk -norc -pdf -interaction=nonstopmode -file-line-error -halt-on-error \
      -outdir="$build_path" "$tex_file"
  )
  cp "$build_path/${tex_file%.tex}.pdf" "$PDF_DIR/$output_name"
}

build_full() {
  validate_source
  compile_latex "paper.tex" "paper_full" "paper_full.pdf"
}

build_blind() {
  validate_source
  compile_latex "paper_blind.tex" "paper_blind" "paper_blind.pdf"
}

build_titlepage() {
  validate_source
  compile_latex "titlepage.tex" "titlepage" "titlepage.pdf"
}

build_highlights() {
  validate_source
  compile_latex "highlights.tex" "highlights" "highlights.pdf"
}

build_graphical_abstract() {
  validate_source
  if ! graphical_abstract_asset >/dev/null; then
    printf 'Skipping graphical abstract: no graphical_abstract asset found in sub_1/.\n'
    return 0
  fi
  compile_latex "graphical_abstract.tex" "graphical_abstract" "graphical_abstract.pdf"
}

build_all() {
  build_full
  build_blind
  build_titlepage
  build_highlights
  build_graphical_abstract
}

export_bundle() {
  local asset=""
  validate_source
  build_blind
  build_titlepage
  build_highlights
  if asset="$(graphical_abstract_asset 2>/dev/null)"; then
    build_graphical_abstract
  fi

  rm -rf "$EXPORT_DIR"
  mkdir -p "$EXPORT_DIR"

  cp "$SOURCE_DIR"/paper.tex "$EXPORT_DIR"/paper.tex
  cp "$SOURCE_DIR"/paper_blind.tex "$EXPORT_DIR"/paper_blind.tex
  cp "$SOURCE_DIR"/titlepage.tex "$EXPORT_DIR"/titlepage.tex
  cp "$SOURCE_DIR"/highlights.tex "$EXPORT_DIR"/highlights.tex
  cp "$SOURCE_DIR"/highlights_content.tex "$EXPORT_DIR"/highlights_content.tex
  cp "$SOURCE_DIR"/settings.tex "$EXPORT_DIR"/settings.tex
  cp "$SOURCE_DIR"/metadata.tex "$EXPORT_DIR"/metadata.tex
  cp "$SOURCE_DIR"/abstract.tex "$EXPORT_DIR"/abstract.tex
  cp "$SOURCE_DIR"/keywords.tex "$EXPORT_DIR"/keywords.tex
  cp "$SOURCE_DIR"/authors.tex "$EXPORT_DIR"/authors.tex
  cp "$SOURCE_DIR"/content.tex "$EXPORT_DIR"/content.tex
  cp "$SOURCE_DIR"/bib.bib "$EXPORT_DIR"/bib.bib
  cp "$PDF_DIR"/paper_blind.pdf "$EXPORT_DIR"/paper_blind.pdf
  cp "$PDF_DIR"/titlepage.pdf "$EXPORT_DIR"/titlepage.pdf
  cp "$PDF_DIR"/highlights.pdf "$EXPORT_DIR"/highlights.pdf

  if [[ -n "$asset" ]]; then
    cp "$SOURCE_DIR"/graphical_abstract.tex "$EXPORT_DIR"/graphical_abstract.tex
    cp "$SOURCE_DIR/$asset" "$EXPORT_DIR/$asset"
    cp "$PDF_DIR"/graphical_abstract.pdf "$EXPORT_DIR"/graphical_abstract.pdf
  fi
}

clean_outputs() {
  rm -rf "$BUILD_DIR" "$REPO_ROOT/dist"
  find "$SOURCE_DIR" -maxdepth 1 -type f \
    \( -name '*.aux' -o -name '*.bbl' -o -name '*.blg' -o -name '*.fdb_latexmk' \
       -o -name '*.fls' -o -name '*.log' -o -name '*.out' -o -name '*.spl' \
       -o -name '*.acn' -o -name '*.acr' -o -name '*.alg' -o -name '*.ist' \) \
    -delete
  rm -f "$SOURCE_DIR/paper.pdf" "$SOURCE_DIR/paper_blind.pdf" "$SOURCE_DIR/highlights.pdf" "$SOURCE_DIR/titlepage.pdf"
}

case "$TARGET" in
  full)
    build_full
    ;;
  blind)
    build_blind
    ;;
  titlepage)
    build_titlepage
    ;;
  highlights)
    build_highlights
    ;;
  graphicalabstract)
    build_graphical_abstract
    ;;
  all)
    build_all
    ;;
  export)
    export_bundle
    ;;
  clean)
    clean_outputs
    ;;
  *)
    die "Unknown target '$TARGET'. Use: full, blind, titlepage, highlights, graphicalabstract, all, export, clean."
    ;;
esac
