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

    test("abc_;");
    test("_;");
    test("124;");
    test(".456;");
    test("1.097;");
    test("1.7;");

    test("46 / 6;");
    test("46?  abc: cde;");
    test("90.0;");
    test("a * *abc;");

    test("f();");
    test("ftg(2,4,a);");
    test("ftg(2, 4, a);");
    test("abd(.8, a);");
    test("f(43)?  abc_/45.6: 9*4 +3;");

    // fail
    test("1abs;");
    test("46 + / 6;");
    test("46 / 6 +;");
    test("abc abc;");
    test("f(43)?  2abc/45.6: 9*4 +3;");
  return 0;
}

