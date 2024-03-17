#include "test.hpp"
#include <algorithm> 

Test::Test(const std::string_view name) : m_name(name) {}

std::string Test::name() const {
    return m_name;
}

std::string Test::reversed_name() const {
    auto rev = m_name;
    std::reverse(rev.begin(), rev.end());
    return rev;
}

int main(int argc, char** argv) {
    Test app("hello");
    return 0;
}
