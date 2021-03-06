#!/usr/bin/env bash

# Copyright 2017 cc-wrapper authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Outputs a C compatible header file enumerating all of the compiler
# executables in the environment. The structs are compatible with
# `struct exec_info` which can be found in src/execinfo.h
#
# Please refer to build/compiler_exes.sh for the input environment
# for running this script as it does the heavy lifting

set -e
set -o pipefail
set -x

if [ "$BUILD_AND_CHECK" = "1" ]; then
  exec "$(dirname "$0")/build_and_check.sh"
elif [ "$FORMAT_AND_LINT" = "1" ]; then
  exec "$(dirname "$0")/format_and_lint.sh"
else
  echo "Bad config" >&2
  exit 1
fi
