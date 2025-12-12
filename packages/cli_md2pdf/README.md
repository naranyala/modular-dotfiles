```bash 

# Convert one file
md2pdf readme.md

# Convert one file to specific PDF
md2pdf notes.md -o document.pdf

# Convert all .md in current folder
md2pdf .

# Convert all in a folder → put PDFs in ./out
md2pdf docs/ -o out/

# Force overwrite existing PDFs
md2pdf . -f

```
