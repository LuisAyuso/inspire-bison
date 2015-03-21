# inspire-bison
A bison parser for the Inspire parallel language 

The aim is to generate a LALR(n) parser for the Inspire parallel language.
- "easy" to maintain.
- decent error reporting.
- use as little in-house code as possible. (did anyone build that feature before?) 

The code is based in the Bison calc++ example, it can be found in the Bison source code tarball at the path:
Bison-3.0.4/examples/calc++

#####Features/requirements: 
- Full C++ for easy integration
- Parse from File, String or stdin (this last one comes for free ;) )
- Nice lex/sync/sema... error reporting with locations, please
  
#####Uses:
- Bison 3.0 minim (have you seen the c++ code produced by 2.7?????? I rather choose dead)
- Flex (I use 2.5, would definitely love to update or get rid of it)
