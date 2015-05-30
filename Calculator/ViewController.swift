//
//  ViewController.swift
//  Calculator
//
//  Created by EB on 4/13/15.
//  Copyright (c) 2015 Test Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

//    var operandStack = Array<Double>()
    var userIsInTheMiddleOfTypingANumber = false
    let dotString = "."
    
    var brain = CalculatorBrain()

    @IBAction func appendDigit(sender: UIButton) {
        
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            var inputString = display.text! + digit
            var existDotString = inputString.rangeOfString(dotString)
            var countOfDotString = inputString.componentsSeparatedByString(dotString).count - 1
            if existDotString != nil && countOfDotString > 1 {
                println("Not a legal floating point number")
            } else {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func createVariableButton(sender: UIButton) {

        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
            updateHistoryText()
        } else {
            displayValue = nil
            updateHistoryText()
        }

    }
    
    
    @IBAction func setVariableButton(sender: UIButton) {
        
        if displayValue != nil {
            brain.variableValues["M"] = displayValue
            displayValue = brain.evaluateVariable()
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clearButton(sender: UIButton) {
        
        history.text = "History: "
        displayValue = nil
        brain.clearCalculator()
//        operandStack.removeAll()
        
    }
    
    @IBAction func backButton(sender: UIButton) {
            
        if userIsInTheMiddleOfTypingANumber && countElements(display.text!) > 1 {
            display.text = dropLast(display.text!)
        } else if userIsInTheMiddleOfTypingANumber && countElements(display.text!) == 1 {
            display.text = " "
            userIsInTheMiddleOfTypingANumber = false
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        
//        if userIsInTheMiddleOfTypingANumber {
//            enter()
//        }
//        
//        if let operation = sender.currentTitle {
//            if let result = brain.performOperation(operation) {
//                displayValue = result
//            } else {
//                displayValue = 0
//            }
//            
//        }
        
        
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            switch operation {
                case "±":
                    changeSign()
                    userIsInTheMiddleOfTypingANumber = true
                    println("changing sign")
                default: enter()
            }
        }

        if operation != "±" {
            if let result = brain.performOperation(operation) {
                displayValue = result
//                operandStack.append(displayValue!)
//                history.text = history.text! + " \(displayValue!)= " + operation
                updateHistoryText()
//                println("operandStack = \(operandStack)")
            } else {
                displayValue = nil
                updateHistoryText()
            }
        }
        
//        switch operation {
//            case "×": performOperation { $0 * $1 }
//            case "÷": performOperation { $1 / $0 }
//            case "+": performOperation { $0 + $1 }
//            case "−": performOperation { $1 - $0 }
//            case "√": performOperation { sqrt($0) }
//            case "sin": performOperation { sin($0) }
//            case "cos": performOperation { cos($0) }
//            default: break
//        }
        
    
    }
    
    
    func changeSign() {
        
        let negativePrefix: String = "-"
        
        if display.text!.hasPrefix(negativePrefix) {
            display.text!.removeAtIndex(display.text!.startIndex)
        } else {
            display.text = "-" + display.text!
        }
        
    }
    
    func updateHistoryText() {
        history.text = brain.historyString + "="
    }
    

//    func performOperation(operation: (Double, Double) -> Double) {
//        if operandStack.count >= 2 {
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            enter()
//        }
//    }
//    
//    func performOperation(operation: Double -> Double) {
//        if operandStack.count >= 1 {
//            displayValue = operation(operandStack.removeLast())
//            enter()
//        }
//    }
    
    

    
    
    @IBAction func enter() {

        userIsInTheMiddleOfTypingANumber = false
        
        switch display.text! {
            case "π":
                brain.pushConstant("π")
                updateHistoryText()
//                operandStack.append(M_PI)
//                history.text = history.text! + " " + display.text!
//                println("operandStack = \(operandStack)")
            case "-π":
                brain.pushConstant("-π")
                updateHistoryText()
//                operandStack.append(-1*M_PI)
//                history.text = history.text! + " " + display.text!
//                println("operandStack = \(operandStack)")
            default:
                if displayValue != nil {
                    if let result = brain.pushOperand(displayValue!) {
                        displayValue = result
                        updateHistoryText()
//                        operandStack.append(displayValue!)
//                        history.text = history.text! + " " + display.text!
//                        println("operandStack = \(operandStack)")
                        
                    } else {
                        displayValue = nil
                    }
                }
        }

        
//        userIsInTheMiddleOfTypingANumber = false
//        if displayValue != nil {
//            operandStack.append(displayValue!)
//            history.text = history.text! + " " + display.text!
//            println("operandStack = \(operandStack)")
//        } else {
//            display.text = "0"
//        }

    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = " "
            }

        }
    }
    
    
}

