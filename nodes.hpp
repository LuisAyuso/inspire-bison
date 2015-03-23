#pragma once

#include<string>

struct NNode{
};

struct NStatement : public NNode{
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

struct NExpression : public NStatement{
};

struct NLiteralExpr : public NExpression{
    int val;
    NLiteralExpr(int value)
    :val (value){
    }
};

struct NSynbolExpr : public NExpression{
    std::string val;
    NSynbolExpr(const std::string sym)
    : val(sym)
    {}
};

struct NUnaryExpr : public NExpression{
    std::string op;
    NExpression expr;
    NUnaryExpr(const std::string& op, const NExpression& expr)
    : op(op), expr(expr)
    {}
};

struct NBinaryExpr : public NExpression{
    int op;
    NExpression left;
    NExpression right;
    NBinaryExpr(int op, const NExpression& left, const NExpression& right)
    : op(op), left(left), right(right)
    {}
} ;

struct NTernaryExpr : public NExpression{
    NExpression cond;
    NExpression yes;
    NExpression no;
    NTernaryExpr(const NExpression& cond, const NExpression& yes, const NExpression& no)
    : cond(cond), yes(yes), no(no)
    {}
};


