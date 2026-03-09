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
submit_all.bat
submit_full.bat
submit_blind.bat
submit_titlepage.bat
submit_highlights.bat
submit_graphicalabstract.bat
submit_export.bat
clean.bat
```

Matching macOS/Linux wrappers are available with the same names and `.sh`
extensions:

```bash
./submit_all.sh
./submit_full.sh
./submit_blind.sh
./submit_titlepage.sh
./submit_highlights.sh
./submit_graphicalabstract.sh
./submit_export.sh
./clean.sh
```

The same wrapper set is also available inside
[`sub_1/`](/Users/patrickkastner/Documents/GitHub/SustainLab/Journal-Paper/sub_1)
for users who prefer to launch commands from the manuscript folder.

## Script Targets

- `submit.sh`: canonical dispatcher; runs the target passed as its first argument
- `submit.bat`: Windows launcher for `submit.sh` via `bash`, Git Bash, or WSL
- `submit_full.*`: builds only `dist/pdf/paper_full.pdf`
- `submit_all.*`: builds the full local PDF set: `paper_full.pdf`, `paper_blind.pdf`, `titlepage.pdf`, `highlights.pdf`, and `graphical_abstract.pdf` when an asset exists
- `submit_blind.*`: builds `dist/pdf/paper_blind.pdf` and sanitizes blind PDF metadata
- `submit_titlepage.*`: builds `dist/pdf/titlepage.pdf`
- `submit_highlights.*`: builds `dist/pdf/highlights.pdf`
- `submit_graphicalabstract.*`: builds `dist/pdf/graphical_abstract.pdf` when an asset exists
- `submit_export.*`: builds the submission artifacts and writes the flattened Elsevier upload bundle to `dist/export/`
- `clean.*`: removes generated build and distribution files
- `sub_1/*.sh` and `sub_1/*.bat`: run the same root-level targets from inside `sub_1/`

## Common Cases

- Use `submit_full.*` when you only want the author-named manuscript PDF for review.
- Use `submit_all.*` when you want every local companion PDF regenerated in one pass.
- Use `submit_export.*` when you want the upload-ready Elsevier package in `dist/export/`.

## Repo Layout

- `sub_1/paper.tex`: canonical `cas-sc` manuscript source for the full paper build
- `sub_1/paper_blind.tex`: blind wrapper that reuses the canonical manuscript source
- `sub_1/titlepage.tex`: standalone title-page artifact with author details
- `sub_1/highlights.tex`: standalone highlights wrapper; pulls bullets from `highlights_content.tex`
- `sub_1/graphical_abstract.tex`: standalone graphical-abstract wrapper; pulls the image asset if present
- `sub_1/abstract.tex`: abstract text inserted into the manuscript build
- `sub_1/keywords.tex`: keyword list inserted into the manuscript build
- `sub_1/highlights_content.tex`: 3 to 5 highlight bullets used by `highlights.tex`
- `sub_1/authors.tex`: author, affiliation, and corresponding-author macros reused by manuscript and title page
- `sub_1/content.tex`: main manuscript sections inserted into `paper.tex`
- `sub_1/metadata.tex`: shared title, short title, journal, and companion-title metadata
- `sub_1/settings.tex`: shared package and formatting setup for the manuscript build
- `sub_1/bib.bib`: bibliography database used by BibTeX

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
