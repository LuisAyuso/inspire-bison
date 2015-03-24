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

    test("for () { abc/45.6; }");
    test("for (int a = 0 .. 45) { abc/45.6; }");
    test("for (int a = .. 45) { abc/45.6; }");
    test("for (int a  8.. 45) { abc/45.6; }");
    test("for (int a =   8.. ) { abc/45.6; }");

    test("for (int<vector<caca<4>>> a =   8.. ) { abc/45.6; }");
    test("for (int<vector<caca<4>> a =   8.. ) { abc/45.6; }");
    test("for (int<vector<caca<4>>> a =   8.. 67) { abc/45.6; }");

    test("while (caca) { abc/45.6; }");
    test("while () { abc/45.6; }");
    test("while (6) abc/45.6; ");

    test("let cacafuti = 5");
    test("let cacafuti = int<5>");

    test("{{}{}}");
    test("{{}{}");
    test("{{let x = int;}{ let y = j;}}");

    // fail
    test("while (wer) abc/45.6 ");
    test("1abs;");
    test("46 + / 6;");
    test("46 / 6 +;");
    test("abc abc;");
    test("f(43)?  2abc/45.6: 9*4 +3;");
  return 0;
}

