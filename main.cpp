#include <iostream>
#include "driver.hpp"

void test(const std::string& x){

  calcxx_driver driver(x);
  driver.parse();
  std::cout << x  << " = " << driver.result << std::endl;

}


int main (int argc, char *argv[])
{
//
//    test("5 + 6");
//    test("456 + 6");
//    test("46 / 6");
//
    test("46 + / 6");
    test("46 / 6");
    test("46 / 6 +");

  return 0;
}

