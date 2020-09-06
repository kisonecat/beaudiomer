#!/usr/bin/env bash

. test-lib.sh || exit 1

cat<<EOF > beatest.tex
\documentclass{beamer}
\usepackage{beaudiomer}
\begin{document}
\begin{frame}
\wait{2}
\end{frame}
\end{document}
EOF

run_lualatex beatest.tex
run_beaudiomer beatest.pdf output.xml

cat <<EOF > expected.xml
<?xml version="1.0" encoding="UTF-8"?>
<movie>
  <video src="page000.png" in="0" out="2"/>
</movie>
EOF

diff_xml expected.xml output.xml || fail_test "bad xml"
test -s page000.png || fail_test "empty png"

pass_test
