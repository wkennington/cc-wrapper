#include <nonstd/string_view.hpp>
#include <vector>

#include "config.h"
#include "env.hpp"
#include "flags.hpp"
#include "generic.hpp"
#include "linker.hpp"
#include "linker/args.hpp"
#include "linker/compiler.hpp"
#include "linker/harden.hpp"
#include "linker/path.hpp"

namespace cc_wrapper {
namespace linker {

int main(const bins::Info &info, nonstd::span<const nonstd::string_view> args) {
  std::vector<nonstd::string_view> combined_args;
  flags::appendFromVar(combined_args, VAR_PREFIX "_LDFLAGS_BEFORE");
  flags::appendFromString(combined_args, WRAPPER_LDFLAGS_BEFORE);

  std::vector<nonstd::string_view> initial_args;
  compiler::filterFlags(initial_args, args,
                        args::hasDynamicLinker(combined_args));
  {
    const auto harden_env = harden::getEnv();
    harden::appendFlags(combined_args, harden_env);
    harden::filterFlags(combined_args, initial_args, harden_env);
  }
  flags::appendFromVar(combined_args, VAR_PREFIX "_LDFLAGS");
  flags::appendFromString(combined_args, WRAPPER_LDFLAGS);
  if (args::isDynamicLinking(initial_args)) {
    flags::appendFromVar(combined_args, VAR_PREFIX "_LDFLAGS_DYNAMIC");
    flags::appendFromString(combined_args, WRAPPER_LDFLAGS_DYNAMIC);
  }

  std::vector<nonstd::string_view> filtered_args;
  path::appendGood(filtered_args, combined_args, env::purePrefixes());
  return generic::main(info, filtered_args);
}

}  // namespace linker
}  // namespace cc_wrapper