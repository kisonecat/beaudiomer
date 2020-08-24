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

run_latex beatest.tex
run_beaudiomer beatest.pdf output.xml

cat <<EOF > expected.xml
<?xml version="1.0" encoding="UTF-8"?>
<movie>
  <video src="page000.png" in="0" out="2"/>
</movie>
EOF

diff_xml expected.xml output.xml || fail_test "bad xml"
test -s page000.png || fail_test "empty png"

run_autocut output.xml autocut.xml || fail_test "autocut failed"

melt_avi autocut.xml output.avi || fail_test "melt failed"

melt_query "//property[@name='length']" output.avi > length.xml

cat <<EOF > expected-length.xml
<property name="length">52</property>
EOF

diff_xml expected-length.xml length.xml || fail_test "length mismatch"

pass_test
