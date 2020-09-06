#!/usr/bin/env bash

. test-lib.sh || exit 1

run_beaudiomer ${data_dir}/noannot.pdf output.xml 2>&1 >/dev/null || broken_test "beaudiomer failed"

fixed_test "unexpected success"
