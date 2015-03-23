#include <iostream>
#include "driver.hpp"
#include "nodes.hpp"




void test(const std::string& x){
    NodeKeeper nk;
    calcxx_driver driver(x, nk);
    driver.parse();
}

int main (int argc, char *argv[])
{

    test("46 + / 6");
    test("46 / 6");
    test("46 / 6 +");
    test("46?  abc: cde");
    test("a * *abc");

  return 0;
}

