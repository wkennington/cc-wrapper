/*
 * Copyright 2018 cc-wrapper authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stddef.h>

#include "execinfo_test_util.h"

const struct exec_info exec_infos[] = {
    {
	.name = "cpp",
	.path = "/no-such-path/bin/cpp",
	.package = "gcc",
	.type = "cc",
	.prefer = 0,
    },
    {
	.name = "gcc",
	.path = "/no-such-path/bin/gcc",
	.package = "gcc",
	.type = "cc",
	.prefer = 0,
    },
    {
	.name = "ld.bfd",
	.path = "/no-such-path/bin/ld.bfd",
	.package = "bfd",
	.type = "ld",
	.prefer = 1,
    },
    {
	.name = "ld.gold",
	.path = "/no-such-path/bin/ld.gold",
	.package = "gold",
	.type = "ld",
	.prefer = 0,
    },
    {
	.name = NULL,
    },
};
