
#CC=gcc-mp-4.8

all: exec

clean:
	@rm location.hh position.hh parser.cpp parser.hpp stack.hh tokens.cpp exec

parser.cpp: parser.y
	bison -d -o $@ $^
	
parser.hpp: parser.cpp

tokens.cpp: scanner.l parser.hpp
	lex -o $@ $^

exec: parser.cpp main.cpp driver.cpp tokens.cpp nodes.hpp
	${CXX} -o $@ *.cpp  -g --std=c++11 -Wno-deprecated-register
