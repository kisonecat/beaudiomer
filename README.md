# beaudiomer

Beaudiomer is a LaTeX package and python script which takes a
[beamer](https://en.wikipedia.org/wiki/Beamer_(LaTeX)) presentation
with additional `\audio` and `\video` and `\wait` commands and
produces an `.xml` file suitable for the
[autocut](https://github.com/kisonecat/autocut)er.

To use this, `git clone` this package into, say, your local TEXMF tree, e.g.,
```bash
cd ~/texmf/tex/latex
git clone https://github.com/kisonecat/beaudiomer.git
```

In the preamble of your beamer file, include `\usepackage{beaudiomer}`
and on the appropriate slides, include
`\audio{the-relevant-audio-file.wav}`.  After you `pdflatex` your
beamer file, the resulting PDF will include special annotations
pointing to the audio file.  To produce an `input.xml` suitable for
[autocut](https://github.com/kisonecat/autocut), use `python
beaudiomer.py filename.pdf` where `filename.pdf` is the PDF that
pdflatex produced.

You can use `\video{a-movie.mp4}` to replace an entire slide with a
video, or `\wait{17}` to wait for 17 seconds on the slide.  Note that
`\audio` commands should be positioned appropriately relative to
`\pause` and the like.

The `\audio` and `\video` and `\wait` commands also accept a frame, e.g.,
```
\begin{frame}
  one, \uncover<2->{two}, and \uncover<3->{three}.

  \wait<1>{0.1}
  \wait<2>{1}
  \wait<3>{5}
  
\end{frame}
```

## Dependencies

Reading annotations was causing pymupdf to segfault, so beaudiomer.py
depends on pymupdf and pypdf2.
