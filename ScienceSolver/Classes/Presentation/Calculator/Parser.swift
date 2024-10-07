//
//  Parser.swift
//  SciCalc
//
//  Created by Niiaz Khasanov on 9/27/24.
//

// Parser class to parse tokens into an expression tree
 class Parser {
    var tokens: [Token]
    var index: Int = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parseExpression() -> ExpressionNode {
        return parseExpression(precedence: 0)
    }
    
    private func parseExpression(precedence: Int) -> ExpressionNode {
        var node = parsePrimary()
        
        while true {
            let token = currentToken()
            let tokenPrecedence = getPrecedence(of: token)
            
            if tokenPrecedence < precedence {
                break
            }
            
            if case .operatorSymbol(let op) = token {
                index += 1
                if op == "!" {
                    // Factorial operator is unary postfix
                    node = .function("factorial", [node])
                    continue
                }
                let nextPrecedence = tokenPrecedence + 1
                let rightNode = parseExpression(precedence: nextPrecedence)
                node = .binaryOperation(node, op, rightNode)
            } else {
                break
            }
        }
        
        return node
    }
    
    private func parsePrimary() -> ExpressionNode {
        let token = currentToken()
        switch token {
        case .number(let value):
            index += 1
            var node: ExpressionNode = .number(value)
            // Check for factorial operator
            if currentToken() == .operatorSymbol("!") {
                index += 1
                node = .function("factorial", [node])
            }
            return node
        case .variable(let name):
            index += 1
            return .variable(name)
        case .operatorSymbol(let op) where op == "-":
            index += 1
            let expr = parseExpression(precedence: 10)
            return .unaryOperation("-", expr)
        case .function(let funcName):
            index += 1
            var args = [ExpressionNode]()
            if currentToken() == .leftParenthesis {
                index += 1
                if currentToken() != .rightParenthesis {
                    while true {
                        let arg = parseExpression()
                        args.append(arg)
                        if currentToken() == .rightParenthesis {
                            break
                        } else if currentToken() == .comma {
                            index += 1
                        } else {
                            // Handle incomplete function arguments
                            return .function(funcName, args)
                        }
                    }
                }
                if currentToken() == .rightParenthesis {
                    index += 1
                }
            } else {
                // Handle incomplete function call
                return .function(funcName, [])
            }
            return .function(funcName, args)
        case .leftParenthesis:
            index += 1
            let expr = parseExpression()
            if currentToken() == .rightParenthesis {
                index += 1
            } else {
                // Handle incomplete parenthesis
                return .incomplete(expr)
            }
            return expr
        case .endOfInput:
            // Handle incomplete expressions
            return .incomplete(nil)
        default:
            // Handle unexpected tokens
            index += 1
            return .error("Unexpected token \(token)")
        }
    }
    
    private func currentToken() -> Token {
        if index < tokens.count {
            return tokens[index]
        } else {
            return .endOfInput
        }
    }
    
    private func getPrecedence(of token: Token) -> Int {
        switch token {
        case .operatorSymbol(let op):
            switch op {
            case "+" , "-":
                return 1
            case "*", "/":
                return 2
            case "^":
                return 4 // Higher precedence for exponentiation
            case "!":
                return 5 // Highest precedence for factorial
            default:
                return 0
            }
        default:
            return 0
        }
    }
}
