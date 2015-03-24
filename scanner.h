#pragma once

namespace insieme{
namespace core{
namespace parser3{

class inspire_driver;

class scanner_wrapper
{
public:
    inspire_driver* driver;
    scanner_wrapper(inspire_driver* driver)
    : driver(driver)
    {}
    virtual void scan_begin() =0;
    virtual void scan_end() =0;

    virtual ~scanner_wrapper(){}
};

class scanner_stdin : public scanner_wrapper{
public:
    scanner_stdin(inspire_driver* driver)
    :scanner_wrapper(driver)
    { }
    void scan_begin();
    void scan_end();
};

class scanner_string : public scanner_wrapper{
    const std::string& str;
public:
    scanner_string(inspire_driver* driver, const std::string& str)
    :scanner_wrapper(driver), str(str)
    { }
    void scan_begin();
    void scan_end();
};
class scanner_file : public scanner_wrapper{
    const std::string& file;
public:
    scanner_file(inspire_driver* driver, const std::string& file)
    :scanner_wrapper(driver), file(file)
    { }
    void scan_begin();
    void scan_end();
};

} // namespace parser3
} // namespace core
} // namespace insieme
