run_latex () {
    base=$(basename $1 .tex)
    pdflatex -halt-on-error $1 1>${base}.stdout 2>${base}.stderr
}

fail_test () {
    printf "FAIL: %s: %s\n" "$test_name" "$1"
    exit 1
}

pass_test () {
    printf "PASS: ${test_name}\n"
    exit 1
}

run_beaudiomer () {
    python3 $project_root/beaudiomer.py $* 2>&1 1>beaudiomer.log
}

run_autocut () {
    autocut $1 $2 1>autocut.log
}

diff_xml () {
    xmllint --format $1 > fmt-$1
    xmllint --format $2 > fmt-$2
    diff -u  fmt-$1 fmt-$2
}

# autocut assumes 25 FPS
melt_avi () {
    melt -quiet -profile atsc_1080p_25 -consumer avformat:$2 $1
}

melt_query () {
    melt -quiet -consumer xml $2 | xmllint --xpath $1 -
}

set -e

project_root=$(dirname `pwd`)
test_name=$(basename $0 .sh)
export TEXINPUTS=${project_root}:
testdir="tmp.${test_name}"
rm -rf "$testdir"
mkdir -p "$testdir"
cd "$testdir"
