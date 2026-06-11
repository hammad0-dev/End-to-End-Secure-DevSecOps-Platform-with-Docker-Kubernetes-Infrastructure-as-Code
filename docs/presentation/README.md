# Presentation

`slides.md` is a **Marp** deck.  Render it to PDF / HTML / PPTX from the
command line (no internet needed once Marp is installed):

```bash
# install Marp CLI (one-time)
npm install -g @marp-team/marp-cli

# from project root
marp docs/presentation/slides.md -o docs/presentation/slides.pdf
marp docs/presentation/slides.md -o docs/presentation/slides.html
marp docs/presentation/slides.md -o docs/presentation/slides.pptx
```

For the live demo, open `slides.html` in any browser and press `f` for
full-screen.  Speaker notes (Marp `<!-- _notes: -->` directives) can be
revealed with `p`.

## What's in the deck

22 slides covering the 7 project phases, the framework matrix, the
rubric self-score, and the live-demo flow.  Designed to fit a 15–20 minute
oral presentation.  Each slide cross-references the file(s) the grader
should open during Q&A.
