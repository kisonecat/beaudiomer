#!/usr/bin/env bash

. test-lib.sh || exit 1

cat<<EOF > beatest.tex
\documentclass{beamer}
\usepackage{beaudiomer}
\begin{document}
\begin{frame}
\audio{a-great-speech.mp4}
\end{frame}
\end{document}
EOF

run_latex beatest.tex
run_beaudiomer beatest.pdf output.xml

cat <<EOF > expected.xml
<?xml version="1.0" encoding="UTF-8"?>
<movie>
  <video src="a-great-speech.mp4" slide="page000.png"/>
</movie>
EOF

diff_xml expected.xml output.xml || fail_test "bad xml"

pass_test
