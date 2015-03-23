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

enum op_code{
    SUM, SUB, MUL, DIV, DEREF, NOT, MOD, MINUS
};

struct NStatement : public NNode{
    virtual std::ostream& operator<< (std::ostream& ) =0;
    virtual ~NStatement (){}
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

template <typename T, typename R = void>
class Visitor : public T{

public:

    R visit(NNode* n){
    
        if (dynamic_cast<NLiteralExpr*>(n)){
            return static_cast<T*>(this)->visitNLiteralExpr(n);
        }
        if (dynamic_cast<NSynbolExpr*>(n)){
            return static_cast<T*>(this)->visitNSynbolExpr(n);
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

