# Journal Paper Submission Workflow

Reusable LaTeX workflow for `Sustainable Cities and Society` / Elsevier submission packages.

## Requirements

- `latexmk`
- `pdflatex`
- `bibtex`

## Canonical Commands

Run all commands from the repository root.

```bash
./submit.sh full
./submit.sh blind
./submit.sh titlepage
./submit.sh highlights
./submit.sh all
./submit.sh export
./submit.sh clean
```

Windows wrappers are also available:

```bat
submit.bat all
run_compile.bat
run_export.bat
run_clean.bat
```

## Repo Layout

- `sub_1/paper.tex`: canonical `cas-sc` manuscript source
- `sub_1/paper_blind.tex`: blind wrapper around the canonical source
- `sub_1/titlepage.tex`: separate author-details file for double anonymized review
- `sub_1/highlights.tex`: standalone highlights artifact
- `sub_1/graphical_abstract.tex`: optional standalone graphical abstract artifact
- `sub_1/abstract.tex`: abstract body
- `sub_1/keywords.tex`: Elsevier keyword list
- `sub_1/highlights_content.tex`: 3 to 5 highlight bullets
- `sub_1/authors.tex`: author metadata reused across outputs
- `sub_1/content.tex`: manuscript body
- `sub_1/bib.bib`: bibliography database

## Validation

`submit.sh` validates the source before submission builds. It fails when it finds:

- placeholder tokens such as `TITLE`, `KEYWORD`, `HIGHLIGHT`, `Author2`, or `example-image`
- active draft markers such as `\todo`, `\todoo`, or `\rewrite`
- an abstract longer than 250 words
- fewer than 1 or more than 7 keywords
- fewer than 3 or more than 5 highlights
- a highlight longer than 85 characters
- an empty bibliography
- no citation command in the manuscript source

## Outputs

- `dist/pdf/paper_full.pdf`
- `dist/pdf/paper_blind.pdf`
- `dist/pdf/titlepage.pdf`
- `dist/pdf/highlights.pdf`
- `dist/pdf/graphical_abstract.pdf` when a `sub_1/graphical_abstract.(pdf|png|jpg|jpeg)` asset exists
- `dist/export/` flattened upload package for Editorial Manager

## Notes

- The export step keeps all upload files at one directory level to match Elsevier LaTeX upload guidance.
- The manuscript is tuned to the current `Sustainable Cities and Society` guidance as verified on March 9, 2026, and now uses Elsevier's `cas-sc` class.
