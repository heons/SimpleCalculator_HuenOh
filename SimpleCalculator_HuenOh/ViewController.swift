//
//  ViewController.swift
//  MAPD714_F2019_Assign01_Calc_HuenOh
//
//  Created by HUEN_OH on 2019-09-18.
//  Copyright © 2019 Centennial College. All rights reserved.
//
/*
 File Name: ViewController.swift
 Author's Name: Huen Oh
 StudentID: 301082798
 Date: 2019.09.29
 App description: The Calculator; Simple calculator
 Version information: 1.2 - multiple operand hit, result reuse
 */

import UIKit

/**
 View Controller class.
 */
class ViewController: UIViewController {

    /* Outlets */
    @IBOutlet weak var calHistory04: UILabel! // Label for calculation history line04
    @IBOutlet weak var calHistory03: UILabel! // Label for calculation history line03
    @IBOutlet weak var calHistory02: UILabel! // Label for calculation history line02
    @IBOutlet weak var calHistory01: UILabel! // Label for calculation history line01
    @IBOutlet weak var calEquation: UILabel!  // Label for current equation
    @IBOutlet weak var calResult: UILabel!    // Label for current number and result of the calcuation
    
    /* Member Variables */
    // Enums for Operands - It is a type!!!
    private enum Operands : String {case mod="mod", div="÷", mul="x", sub="-", add="+"}
    
    // Special result : nan, inf
    private let m_spResultNan = "nan"
    private let m_spResultInf = "inf"
    
    // Dictionary for operands' priority
    private let m_dictOperands:[String: Int] = [Operands.mod.rawValue:1
                                                , Operands.div.rawValue:1
                                                , Operands.mul.rawValue:1
                                                , Operands.sub.rawValue:0
                                                , Operands.add.rawValue:0]
    private var m_isFirstHit = true    // To check if it is first hit after an operand hit
    private var m_sign:Bool = true     // Sign for current typed number (true : positive, false : negative)
    private var m_number:String = "0"  // Current typed number
    private var m_operand:String = ""  // Current operand
    private var m_equation:String = "" // Current typed equation
    
    private var m_listNumbers:[String] = [String]()  // List of Numbers
    private var m_listOperands:[String] = [String]() // List of Operands
    
    
    //
    /**
     When the View is loaded.
     Initialize some variables.
     
     - Parameters: None
     
     - Returns: None
     */
    override func viewDidLoad() {
        // Set font properties of calEquation
        calEquation.numberOfLines = 0
        calEquation.adjustsFontSizeToFitWidth = true
        calEquation.minimumScaleFactor = 0.1
        
        // Set font properties of calResult
        calResult.font = UIFont.systemFont(ofSize: 80.0)
        calResult.adjustsFontSizeToFitWidth = true
        calResult.minimumScaleFactor = 0.1
        
       // Set font properties of calHistory
        calHistory01.adjustsFontSizeToFitWidth = true
        calHistory02.adjustsFontSizeToFitWidth = true
        calHistory03.adjustsFontSizeToFitWidth = true
        calHistory04.adjustsFontSizeToFitWidth = true
        calHistory01.minimumScaleFactor = 0.1
        calHistory02.minimumScaleFactor = 0.1
        calHistory03.minimumScaleFactor = 0.1
        calHistory04.minimumScaleFactor = 0.1
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //calResult.font = UIFont.systemFont(ofSize: 20.0)
        // Initialize member variables
        initVariables()
    }

    // TODO : Seperate it to functions or make cal class
    /**
     Handelr for buttons.
     Do user-interaction when buttons are pressed.
     
     - Parameters:
     - sender: A pressed button object as UIButton.
     
     - Returns: None
     */
    @IBAction func CalButtons(_ sender: UIButton) {
        let calButton = sender.titleLabel?.text ?? ""
        
        // Debug output
        print("Current input value/button : \(m_number) / \(calButton)")
        
        //check : devide by zero
        switch(calButton)
        {
            // Clear everything
            case "AC":
                initVariables()
                break;
            
            // Change sign of a number
            case "+/-":
                // Doesn't apply for 0
                if(m_number == "0") {
                    break;
                }
                
                // Update sign of the number
                if (m_sign == false) {
                    m_number = String(m_number[m_number.index(after:m_number.startIndex)...])
                } else {
                    m_number = "-" + m_number
                }
                m_sign = !m_sign
                
                // Update Display
                calResult.text = m_number
                calEquation.text = m_equation + m_operand + updateSignOfNumber(number:m_number)
                break;
            
            // Operands
            case Operands.mod.rawValue
                , Operands.div.rawValue
                , Operands.mul.rawValue
                , Operands.sub.rawValue
                , Operands.add.rawValue:
                
                    if (!m_isFirstHit) {
                        // Do calucation of current equation and update result
                        
                        // Add to list
                        m_listNumbers.append(m_number)
                        m_listOperands.append(calButton)
                        
                        // Update and display the equation
                        m_equation = m_equation + m_operand + updateSignOfNumber(number:m_number)
                        calEquation.text = m_equation + calButton
                        
                        // Display current result
                        calResult.text = doCalEquation()
                        
                        // Clear and Update
                        m_operand = calButton
                        m_number = "0"
                        m_sign = true
                        m_isFirstHit = true // true to first hit -> now operand is not applicable
                        
                    } else {
                        // Update the operand
                        if(!m_listOperands.isEmpty) {
                            m_operand = calButton
                            m_listOperands[m_listOperands.endIndex - 1] = m_operand
                            calEquation.text = m_equation + m_operand
                        }
                    }
                    break;
            
            // Do calcuation and show the result
            case "=":
                if (!m_isFirstHit) {
                    
                    // Condition to not work if there is only one number
                    if m_listNumbers.endIndex == 0 { break; }
                    
                    // Append number to the number list
                    m_listNumbers.append(m_number)
                    
                    // Do the calcuation
                    let calNum = doCalEquation()
     
                    //set text and reset
                    let strFinalEquation = m_equation + m_operand + updateSignOfNumber(number:m_number) + "=" + calNum
                    initVariables()
                    
                    // Update history
                    calHistory04.text = calHistory03.text
                    calHistory03.text = calHistory02.text
                    calHistory02.text = calHistory01.text
                    calHistory01.text = strFinalEquation
                    //m_isFirstHit = true  // true to first hit -> now operand is not applicable
                    
                    // Check the result and decide if to keep the result or not
                    if (m_spResultInf != calNum) && (m_spResultNan != calNum) {
                        // If the result is not special case keep the number
                        m_number = calNum
                        calResult.text = m_number
                        calEquation.text = calNum
                        m_isFirstHit = false
                    }
                    
                    // Check and update the sign of the number
                    if (calNum.contains("-")) {
                        m_sign = false
                    }
                }
                break;
            
            // A point
            case ".": //no-activate after operand
                 m_isFirstHit = false // false to first hit -> now operand is applicable
                if (m_number.contains(".")) {
                    print(". is already here")
                } else {
                    m_number += calButton
                    calResult.text = m_number
                    calEquation.text = m_equation + m_operand + updateSignOfNumber(number:m_number)
                }
                break;
            
            // Numbers
            default:
                 m_isFirstHit = false // false to first hit -> now operand is applicable
                // Check if the current typed value is 0
                if (m_number == "0") {
                    m_number = calButton
                } else {
                    m_number = m_number + calButton
                }
                calResult.text = m_number
                calEquation.text = m_equation + m_operand + updateSignOfNumber(number:m_number)
        }
    }
    
    /**
     Initialize/Reset member variables.
     
     - Parameters: None
     
     - Returns: None
     */
    func initVariables() {
        calResult.text = "0"
        calEquation.text = ""
        
        m_isFirstHit = true
        m_sign = true
        m_number = "0"
        m_operand = ""
        m_equation = ""
        
        m_listNumbers = [String]()
        m_listOperands = [String]()
    }
    
   
    /**
     Update sign of a number.
     
     - Parameters:
     - number: A number as String

     - Returns: Positive - number, Negative - (-number) as String
     */
    func updateSignOfNumber(number:String)->String{
        if (m_sign == false) {
            return "(" + number + ")"
        } else {
            return number
        }
    }
    
    /**
     Do calcuation with two numbers and one operand.
     
     - Parameters:
     - strNum1: The 1st number for the operation as String.
     - strNum2: The 2nd number for the operation as String.
     - strOp: An operand as String.
     
     - Returns: Result of operation as String.
     */
    func calOperand(strNum1:String, strNum2:String, strOp:String)->String {
        let num1 = Double(strNum1)!
        let num2 = Double(strNum2)!
        var calNum : Double = 0
        
        switch (strOp) {
            case Operands.add.rawValue:
                calNum = num1 + num2
            case Operands.sub.rawValue:
                calNum = num1 - num2
            case Operands.mod.rawValue:
                calNum = num1.truncatingRemainder(dividingBy: num2) // div 0? -> nan
            case Operands.div.rawValue:
                calNum = num1 / num2 // div 0? -> inf
            case Operands.mul.rawValue:
                calNum = num1 * num2
            default:
                calNum = 0
        }
        
        return String(calNum)
    }
    
    /**
     Do caculation from the equation.
     
     - Parameters: None
     
     - Returns: Result of the calculation from the equation as String.
     */
    func doCalEquation()->String {
        // For Step1 : Copy list of operands and numbers
        let listOprOrg = m_listOperands
        var listNumOrg = m_listNumbers
        
        // For Step2 : list of perands and numbers
        var listOprTmp = [String]()
        var listNumTmp = [String]()
        
        var calNum = listNumOrg[0] // Final calculation result
        
        // Step 1 : x, /, %
        let lenNums = listNumOrg.endIndex
        let lenOprs = listOprOrg.endIndex
        for (index, _) in listNumOrg.enumerated()
        {
            // Condition to exit : no operand
            if (0 == lenOprs) {
                break
            }
            
            if (index + 1 == lenNums) { // Check second number
                listNumTmp.append(listNumOrg[index])
                break;
            } else {
                let op = listOprOrg[index]
                let num1 = listNumOrg[index]
                let num2 = listNumOrg[index+1]
                
                if (1 == m_dictOperands[op]) {
                    // x, /, % : Calculate
                    calNum = calOperand(strNum1: num1, strNum2: num2, strOp: op)
                    listNumOrg[index+1] = calNum
                    
                    // Check special result and return - the equation is not valid to compute
                    if (calNum.contains(m_spResultNan)) {
                        return m_spResultNan
                    }
                    if (calNum.contains(m_spResultInf)) {
                        return m_spResultInf
                    }
                    
                } else {
                    // +, - : add to the lists for step2
                    listOprTmp.append(op)
                    listNumTmp.append(num1)
                }
            }
            print("calNum step1: \(calNum)")
        }
        
        
        // Step 2 : +, -
        let lenNumsTmp = listNumTmp.endIndex
        let lenOprsTmp = listOprTmp.endIndex
        for (index, _) in listNumTmp.enumerated() {
            // Condition to exit : no operand
            if (0 == lenOprsTmp) {
                calNum = listNumTmp[0]
                break
            }
            
            if (index + 1 == lenNumsTmp) { // Check second number
                calNum = listNumTmp[index]
                break;
            } else {
                let op = listOprTmp[index]
                let num1 = listNumTmp[index]
                let num2 = listNumTmp[index+1]
                
                calNum = calOperand(strNum1: num1, strNum2: num2, strOp: op)
                listNumTmp[index+1] = calNum
            }
            
            print("calNum step2: \(calNum)")
        }
        
        return calNum
    }
    
}

