#pragma once
#include <nonstd/span.hpp>
#include <nonstd/string_view.hpp>
#include <stdexcept>

namespace cc_wrapper {
namespace path {

class PurityError : public std::runtime_error {
public:
  PurityError(nonstd::string_view path);
};

bool isPure(nonstd::string_view path,
            nonstd::span<const nonstd::string_view> pure_prefixes);

}  // namespace path
}  // namespace cc_wrapper