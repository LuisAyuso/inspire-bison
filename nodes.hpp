#pragma once

#include<string>
#include<iostream>
#include<cassert>
#include<vector>

struct NNode{
    
    virtual std::ostream& operator<< (std::ostream& ) =0;
    virtual ~NNode (){}
};

class NodeKeeper{

    std::vector<NNode*> container;
    NodeKeeper(const NodeKeeper&){}
public:
    NodeKeeper(){}
    ~NodeKeeper() {
        for(auto ptr : container){
            delete ptr;
        }
    }

    template <typename T, typename ... Params>
    T* getNode(Params ... args){
        T* tmp = new T(args...);
        container.push_back(tmp);
        return tmp;
    }
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

struct NType : public NNode{
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NLitType : public NType{
    std::string name;
    NLitType(const std::string& name)
    :name(name)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NIntTypeParam : public NType{
    std::string val;
    NIntTypeParam(const std::string& val)
    :val(val)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NComposedType : public NType{
    std::string name;
    std::vector<NType*> tparams;
    NComposedType(const std::string& name, const std::vector<NType*> tparams)
    :name(name), tparams(tparams)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NFuncType : public NType{
    std::vector<NType*> tparams;
    NType* ret;
    NFuncType(const std::vector<NType*>& tparams, NType* ret)
    :tparams(tparams), ret(ret)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};



/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

enum op_code{
    SUM, SUB, MUL, DIV, DEREF, NOT, MOD, MINUS, SUBSCRIPT, MEMBACCESS
};

class NExpression;
class NSynbolExpr;

struct NStatement : public NNode{
    virtual std::ostream& operator<< (std::ostream& ) =0;
    virtual ~NStatement (){}
};

struct NWhileLoop : public NStatement{

    NExpression* cond;
    NStatement* body;
    NWhileLoop (NExpression* cond, NStatement* body)
    :cond(cond), body(body)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NForLoop : public NStatement{
    NType* iteratorType;
    NSynbolExpr* it;
    NExpression* lbound;
    NExpression* ubound;
    NStatement* body;
    NForLoop (NType* iteratorType, NSynbolExpr* it, NExpression* lbound, NExpression* ubound, NStatement* body)
    : iteratorType(iteratorType), it(it), lbound(lbound), ubound(ubound), body(body)
    { }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NCompound : public NStatement{
    std::vector<NStatement*> stms;
    NCompound(const std::vector<NStatement*>& stmts)
    :  stms(stmts.begin(), stmts.end())
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

struct NExpression : public NStatement{
    virtual std::ostream& operator<< (std::ostream& ) =0;
    virtual ~NExpression (){}
};

struct NLiteralExpr : public NExpression{
    std::string val;
    NLiteralExpr(const std::string& value)
    :val (value){
    }
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NSynbolExpr : public NExpression{
    std::string val;
    NSynbolExpr(const std::string sym)
    : val(sym)
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NCallExpr : public NExpression{
    NExpression* func;
    std::vector<NExpression*> args;
    NCallExpr(NExpression* func, const std::vector<NExpression*>& args)
    : func(func), args(args.begin(), args.end())
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NUnaryExpr : public NExpression{
    op_code op;
    NExpression* expr;
    NUnaryExpr(op_code op, NExpression* expr)
    : op(op), expr(expr)
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

struct NBinaryExpr : public NExpression{
    op_code op;
    NExpression *left;
    NExpression *right;
    NBinaryExpr(op_code op, NExpression* left, NExpression* right)
    : op(op), left(left), right(right)
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
} ;

struct NTernaryExpr : public NExpression{
    NExpression *cond;
    NExpression *yes;
    NExpression *no;
    NTernaryExpr(NExpression* cond, NExpression* yes, NExpression* no)
    : cond(cond), yes(yes), no(no)
    {}
    virtual std::ostream& operator<< (std::ostream& os) {
        return os;
    }
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

template <typename T, typename R = void>
class Visitor : public T{

public:

    R visit(NNode* n){

        if (dynamic_cast<NCompound*>(n)){
            return static_cast<T*>(this)->visitNCompound(n);
        }
        if (dynamic_cast<NLiteralExpr*>(n)){
            return static_cast<T*>(this)->visitNLiteralExpr(n);
        }
        if (dynamic_cast<NSynbolExpr*>(n)){
            return static_cast<T*>(this)->visitNSynbolExpr(n);
        }
        if (dynamic_cast<NCallExpr*>(n)){
            return static_cast<T*>(this)->visitNCallExpr(n);
        }
        if (dynamic_cast<NUnaryExpr*>(n)){
            return static_cast<T*>(this)->visitNUnaryExpr(n);
        }
        if (dynamic_cast<NBinaryExpr*>(n)){
            return static_cast<T*>(this)->visitNBinaryExpr(n);
        }
        if (dynamic_cast<NTernaryExpr*>(n)){
            return static_cast<T*>(this)->visitNTernaryExpr(n);
        }

        return R();
    }
};

