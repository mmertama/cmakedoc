#pragma once

#include <string>
#include <string_view>

/**
 * @brief Test app
 * 
 */
class Test {
    public:
    
    /**
     * @brief Construct a new Test object
     * 
     * @param name 
     */
    Test(const std::string_view name);

    /**
     * @brief get name 
     * 
     * @return string_view 
     */
    std::string name() const;

    /**
     * @brief get reversed name
     * 
     * @return string_view 
     */
    std::string reversed_name() const;
    
    private:
    const std::string m_name;
};