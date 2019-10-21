#!/bin/sh
set -e
set -f
set -u

valid_tools="as ar lld ld ld.bfd ld.gold ld.lld
             nm objdump objcopy ranlib readelf strip"
if [ "$PREFERRED_COMPILER" = 'no' -o "$PREFERRED_COMPILER" = 'gcc' ]; then
  valid_tools="$valid_tools gcc g++ gcc-ar gcc-nm gcc-ranlib"
fi
if [ "$PREFERRED_COMPILER" = 'no' -o "$PREFERRED_COMPILER" = 'clang' ]; then
  valid_tools="$valid_tools clang clang++"
fi

linked_tools=""

extra_args="
cpp -E
"

types="
clang GCC_COMPILER
clang++ GXX_COMPILER
gcc GCC_COMPILER
g++ GXX_COMPILER
gcc-ar GCC_WRAPPER
gcc-nm GCC_WRAPPER
gcc-ranlib GCC_WRAPPER
ld LINKER
ld.bfd LINKER
ld.gold LINKER
ld.lld LINKER
lld LINKER
"

info_func="
clang make_gcc_info
clang++ make_gcc_info
gcc make_gcc_info
g++ make_gcc_info
"

syms="
clang cc cpp
clang++ c++
gcc cc cpp
g++ c++
"

prefix_map_flags="
clang $PREFIX_MAP_FLAG_CLANG
clang++ $PREFIX_MAP_FLAG_CLANG
gcc $PREFIX_MAP_FLAG_GCC
g++ $PREFIX_MAP_FLAG_GCC
"

get_type() {
  local t
  t="$(echo "$types" | grep "^$1 " | awk '{print $2}')"
  echo "${t:-GENERIC}"
}

get_extra_args() {
  echo "$extra_args" | grep "^$1 " | awk \
    'BEGIN { printf "{"; } { for(i = 2; i <= NF; i++) { printf "\"" $i "\","; } } END { printf "}"; }'
}

get_syms() {
  echo "$syms" | grep "^$1 " | awk '{$1=""; print $0}'
}

get_prefix_map_flag() {
  local f
  f="$(echo "$prefix_map_flags" | grep "^$1 " | awk '{print $2}')"
  if [ -n "$f" ]; then
    echo "\"$f\""
  else
    echo 'nonstd::nullopt'
  fi
}

get_info_func() {
  local f
  f="$(echo "$info_func" | grep "^$1 " | awk '{print $2}')"
  if [ -n "$f" ]; then
    echo "$f"
  else
    echo 'make_info'
  fi
}

_make_info() {
  local refname="$1"
  local tool="$2"
  local name="$3"
  local file="$4"
  local class="$5"
  local extra="${6-}"

  local t="$(get_type "$tool")"
  local args="$(get_extra_args "$name")"
  echo "map.emplace(\"$refname\", std::unique_ptr<Info>(new $class(\"$TARGET${TARGET:+-}$name\", Type::$t, \"$file\", $args$extra)));"
}

make_info() {
  local tool="$1"
  local name="$2"
  local file="$3"
  shift 3
  local class="${1-Info}"
  if [ "$#" -gt 1 ]; then
    shift
  fi

  if [ -n "$TARGET" ]; then
    _make_info "$TARGET-$name" "$tool" "$name" "$file" "$class" "$@"
  fi
  _make_info "$name" "$tool" "$name" "$file" "$class" "$@"
}

make_gcc_info() {
  local tool="$1"

  local f="$(get_prefix_map_flag "$tool")"
  make_info "$@" GccInfo ", $f"
}

exec 3>"$1"
exec 4>"$2"

echo '#include "bins.hpp"' >&3
echo '' >&3
echo 'namespace cc_wrapper {' >&3
echo 'namespace bins {' >&3
echo 'InfoMap makeInfoMap() {' >&3
echo 'InfoMap map;' >&3
oldifs="$IFS"
IFS=":"
for dir in $TOOLDIRS; do
  IFS="$oldifs"
  for file in $(ls $dir); do
    valid=
    for tool in $valid_tools; do
      [ "$TARGET${TARGET:+-}$tool" = "$file" ] && valid="$tool"
    done
    [ -n "$valid" ] || continue
    afile="$(readlink -f "$dir/$file")"
    func="$(get_info_func "$valid")"
    for s in "$valid" $(get_syms "$valid"); do
      linked=
      for tool in $linked_tools; do
        [ "$s" = "$tool" ] && linked=1
      done
      if [ -n "$linked" ]; then
        echo "WARNiNG: Skipping duplicate tool $s" >&2
        continue
      fi
      linked_tools="$linked_tools $s"
      "$func" "$valid" "$s" "$afile" >&3
      echo "$s" >&4
    done
  done
done
echo 'return map;' >&3
echo '}' >&3
echo 'const InfoMap& getInfoMap() {' >&3
echo 'static InfoMap map = makeInfoMap();' >&3
echo 'return map;' >&3
echo '}' >&3
echo '}' >&3
echo '}' >&3
