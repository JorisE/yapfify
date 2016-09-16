#!/bin/bash

# run_tests.sh is used only to get the DATA_DIR. It feels like there should be a
# better way to do this.
DATA_DIR=$(pwd)/test/data/ cask exec ert-runner -l yapfify.el
