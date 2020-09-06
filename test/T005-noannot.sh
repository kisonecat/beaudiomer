#!/usr/bin/env bash

. test-lib.sh || exit 1

run_beaudiomer ${data_dir}/noannot.pdf output.xml || fail_test "beaudiomer failed"

pass_test
