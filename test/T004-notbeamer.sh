#!/usr/bin/env bash

. test-lib.sh || exit 1

cat<<EOF > beatest.tex
\documentclass{article}
\usepackage{beaudiomer}
\begin{document}
\video{1.mkv}
Hello world
\end{document}
EOF

run_latex beatest.tex || /bin/true

grep -q "Class file not supported"  beatest.stdout || fail_test "missing message"

pass_test
