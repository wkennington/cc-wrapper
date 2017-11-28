/*
 * Copyright 2017 cc-wrapper authors
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

#include "path.h"

ssize_t path_base_split(const char *path)
{
	ssize_t split = -1;
	for (size_t i = 0; path[i] != '\0'; ++i)
		if (path[i] == '/')
			split = i;
	return split;
}

const char *path_base(const char *path)
{
	return path + path_base_split(path) + 1;
}
