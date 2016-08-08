# beaudiomer

Beaudiomer is a package and Ruby script (relying on [MLT](https://www.mltframework.org/bin/view/MLT/MltMelt)) which takes a [beamer](https://en.wikipedia.org/wiki/Beamer_(LaTeX)) presentation with additional `\audio` commands and produces an .MP4 video file of the slides with the given audio.

To use this, `git clone` this package into, say, your local TEXMF/tex/latex, e.g.,
```bash
cd ~/texmf/tex/latex
git clone 
```

In the preamble of your beamer file, include `\usepackage{beaudiomer}` and on the appropriate slide, include `\audio{the-relevant-audio-file.wav}`.  After you `pdflatex` your beamer file, the resulting PDF will include special annotations describing the relevant audio.  Then build an mp4 with `ruby ~/texmf/tex/latex/beaudiomer.rb filename.pdf` where `filename.pdf` is the PDF that pdflatex produced.

