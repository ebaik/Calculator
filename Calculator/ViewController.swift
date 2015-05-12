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

    var operandStack = Array<Double>()
    var userIsInTheMiddleOfTypingANumber = false
    let dotString = "."
    let pi = M_PI

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
    
    @IBAction func signButton(sender: UIButton) {
        
        
        
    }
    
    
    @IBAction func clearButton(sender: UIButton) {
        
        history.text = " "
        operandStack.removeAll()
        
    }
    
    @IBAction func backButton(sender: UIButton) {
            
        if userIsInTheMiddleOfTypingANumber && countElements(display.text!) > 1 {
            display.text = dropLast(display.text!)
        } else if userIsInTheMiddleOfTypingANumber && countElements(display.text!) == 1 {
            display.text = "0"
            userIsInTheMiddleOfTypingANumber = false
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            switch operation {
                case "±":
                    changeSign()
                    userIsInTheMiddleOfTypingANumber = true
                default: enter()
            }
        }
        
        switch operation {
            case "×": performOperation { $0 * $1 }
            case "÷": performOperation { $1 / $0 }
            case "+": performOperation { $0 + $1 }
            case "−": performOperation { $1 - $0 }
            case "√": performOperation { sqrt($0) }
            case "sin": performOperation { sin($0) }
            case "cos": performOperation { cos($0) }
            default: break
        }
        
        if operation != "±" {
            history.text = history.text! + "= " + operation
        }
    
    }
    
    
    func changeSign() {
        
        let negativePrefix: String = "-"
        
        if display.text!.hasPrefix(negativePrefix) {
            display.text!.removeAtIndex(display.text!.startIndex)
        } else {
            display.text = "-" + display.text!
        }
        
    }
    

    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    

    
    
    @IBAction func enter() {
        
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            operandStack.append(displayValue!)
            history.text = history.text! + " " + display.text!
            println("operandStack = \(operandStack)")
        } else {
            display.text = "0"
        }

    }
    
    var displayValue: Double? {
        get {
            switch display.text! {
                case "π":
                    return pi
                case "-π":
                    return -1*pi
                default:
                    return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
        }
        set {
            display.text = "\(newValue!)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    
}

