//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by EB on 5/11/15.
//  Copyright (c) 2015 Test Labs. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var constantValues = [String:Double]()
    var variableValues = [String:Double]()
    private var descriptionStack = [String]()
    private var indexDescription = 0
    var historyString = String()
    
    
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case Constant(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variableString):
                    return variableString
                case .Constant(let constantString):
                    switch constantString {
                        case "π":
                            return "π"
                        case "-π":
                            return "-π"
                        default:
                            return ""
                    }
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    

    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷", { $1 / $0 }))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−", { $1 - $0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        
        constantValues["π"] = M_PI
        constantValues["-π"] = -1*M_PI
            
//        knownOps["×"] = Op.BinaryOperation("×", *)
//        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
//        knownOps["+"] = Op.BinaryOperation("+", +)
//        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
//        knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if variableValues[variable] != nil {
                    return (variableValues[variable], remainingOps)
                } else {
                    return (nil, ops)
                }
            case .Constant(let constant):
                if constant == "π" { return (constantValues["π"], remainingOps) }
                else if constant == "-π" { return (constantValues["-π"], remainingOps) }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
//        if opStack.count > 1 && remainder.isEmpty {
//            opStack.removeAll()
//            opStack.append(Op.Operand(result!))
//        }
        println("\(opStack) = \(result) with \(remainder) left over")
        historyString = self.description
        println("The description = " + historyString)
        println("descriptionStack = \(descriptionStack)")
        return result
    }
    
    func evaluateVariable() -> Double? {
        let (result, remainder) = evaluate(opStack)

        println("\(opStack) = \(result) with \(remainder) left over")
        println("descriptionStack = \(descriptionStack)")
        return result
    }
    
    private func brainContent(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        var returnString = " "
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                returnString = "\(operand)"
                return (returnString, remainingOps)
            case .Variable(let variable):
                returnString = variable
                return (returnString, remainingOps)
            case .Constant(let constant):
                if constant == "π" {
                    returnString = "π"
                    return (returnString, remainingOps)
                }
                else if constant == "-π" {
                    returnString = "-π"
                    return (returnString, remainingOps)
                }
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = brainContent(remainingOps)
                if let operand = operandEvaluation.result {
                    returnString =  symbol + "(\(operand))"
                    return (returnString, operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = brainContent(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = brainContent(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        returnString = "(" + operand2 + symbol + operand1 + ")"
                        return (returnString, op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    
    var description: String {
        get {
            let (result, remainder) = brainContent(opStack)
            // track results of operands and operators as complete strings
            if descriptionStack.count == 0 {  // should always be an operand due to logic in performOperation function
                descriptionStack.append(result!)
            } else {
                // identify that operand added to opStack
                if remainder.count == opStack.count-1 {
                    indexDescription = descriptionStack.count
                    descriptionStack.insert(result!, atIndex: indexDescription)
                }
                // identify that unary operator added to opStack
                else if remainder.count == opStack.count - 2 {                      indexDescription = descriptionStack.count - 1  // track index into descriptionStack array for where to place operation represented by string
                    descriptionStack[indexDescription] = result!
                }
                // else if binary operator added to opStack
                else {
                    // if binary operation, need to replace the last two strings in the descriptionStack array
                    var diff = 2
                    // remove strings from descriptionStack and replace with string representing binary operations
                    if descriptionStack.count == 1 {
                        if result == nil {
                            let opLast = opStack.removeLast()
                            let descriptionLast = descriptionStack.removeLast()
                            descriptionStack.append("(?" + opLast.description + descriptionLast + ")")
                        } else {
                            descriptionStack.removeLast()
                            descriptionStack.append(result!)
                        }
                    } else {
                        for var i = 1; i <= diff; i++ {                        descriptionStack.removeLast()
                        }
                        descriptionStack.append(result!)
                    }
                }
            }
            // convert array to string with commas between array entry items
            return ", ".join(descriptionStack.map( { $0 } ))
        }
    }
    
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushConstant(constant: String) -> Double? {
        opStack.append(Op.Constant(constant))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            if !opStack.isEmpty {
                if opStack.count == 1 { // handle not enough binary operands edge case
                    switch operation {
                        case .BinaryOperation(_, _):
                            println("Not enough operands yet to perform " + symbol + " operation")
                            opStack.append(operation)
                        default:
                            opStack.append(operation)
                    }
                } else {
                    opStack.append(operation)
                }
            }
        }
        return evaluate()
    }
    
    func clearCalculator() {
        opStack.removeAll()
        descriptionStack.removeAll()
        variableValues.removeValueForKey("M")
    }
    
    
    
}
