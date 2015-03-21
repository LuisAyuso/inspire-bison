
#CC=gcc-mp-4.8

all: exec

clean:
	@rm location.hh position.hh parser.cpp parser.hpp stack.hh tokens.cpp

parser.cpp: parser.y
	bison -d -o $@ $^
	
parser.hpp: parser.cpp

tokens.cpp: scanner.l parser.hpp
	lex -o $@ $^

exec: parser.cpp main.cpp driver.cpp tokens.cpp
	${CXX} -o $@ *.cpp --std=c++11