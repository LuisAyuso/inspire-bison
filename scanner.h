class calcxx_driver;

class scanner_wrapper
{
public:
    calcxx_driver* driver;
    scanner_wrapper(calcxx_driver* driver)
    : driver(driver)
    {}
    virtual void scan_begin() =0;
    virtual void scan_end() =0;

    virtual ~scanner_wrapper(){}
};

class scanner_stdin : public scanner_wrapper{
public:
    scanner_stdin(calcxx_driver* driver)
    :scanner_wrapper(driver)
    { }
    void scan_begin();
    void scan_end();
};

class scanner_string : public scanner_wrapper{
    const std::string& str;
public:
    scanner_string(calcxx_driver* driver, const std::string& str)
    :scanner_wrapper(driver), str(str)
    { }
    void scan_begin();
    void scan_end();
};
class scanner_file : public scanner_wrapper{
    const std::string& file;
public:
    scanner_file(calcxx_driver* driver, const std::string& file)
    :scanner_wrapper(driver), file(file)
    { }
    void scan_begin();
    void scan_end();
};

