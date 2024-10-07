//
//  SetCalcBtnImages.swift
//  SciCalc
//
//  Created by Niiaz Khasanov on 9/29/24.
//

import UIKit

extension CalculatorViewController {
     func setImageName(_ button: UIButton, _ cellImage: inout UIImage?) {
           if let title = button.currentTitle {
               if title == "nCr" {
                   cellImage = UIImage(named: "nCr")
               }
               if title == "log10" {
                   cellImage = UIImage(named: "log10")
               }
               if title == "(" {
                   cellImage = UIImage(named: "(")
               }
               if title == ")" {
                   cellImage = UIImage(named: ")")
               }
               if title == "," {
                   cellImage = UIImage(named: ",")
               }
               if title == "e^x" {
                   cellImage = UIImage(named: "e^x")
               }
               if title == "x²" {
                   cellImage = UIImage(named: "x²")
               }
               if title == "√" {
                   cellImage = UIImage(named: "√")
               }
               if title == "x^y" {
                   cellImage = UIImage(named: "x^y")
               }
               if title == "n!" {
                   cellImage = UIImage(named: "n!")
               }
               if title == "nPr" {
                   cellImage = UIImage(named: "nPr")
               }
               if title == "y√x" {
                   cellImage = UIImage(named: "y√x")
               }
               if title == "π" {
                   cellImage = UIImage(named: "π")
               }
               if title == "e" {
                   cellImage = UIImage(named: "e")
               }
               if title == "|x|" {
                   cellImage = UIImage(named: "|x|")
               }
               if title == "AC" {
                   cellImage = UIImage(named: "AC")
               }
               if title == "DEL" {
                   cellImage = UIImage(named: "DEL")
               }
               if title == "sin" {
                   cellImage = UIImage(named: "sin")
               }
               if title == "log10" {
                   cellImage = UIImage(named: "log10")
               }
               if title == "cos" {
                   cellImage = UIImage(named: "cos")
               }
               if title == "7" {
                   cellImage = UIImage(named: "7")
               }
               if title == "8" {
                   cellImage = UIImage(named: "8")
               }
               if title == "9" {
                   cellImage = UIImage(named: "9")
               }
               if title == "/" {
                   cellImage = UIImage(named: "divide")
               }
               if title == "tan" {
                   cellImage = UIImage(named: "tan")
               }
               if title == "ln" {
                   cellImage = UIImage(named: "ln")
               }
               if title == "4" {
                   cellImage = UIImage(named: "4")
               }
               if title == "5" {
                   cellImage = UIImage(named: "5")
               }
               if title == "6" {
                   cellImage = UIImage(named: "6")
               }
               if title == "×" {
                   cellImage = UIImage(named: "×")
               }
               if title == "asin" {
                   cellImage = UIImage(named: "asin")
               }
               if title == "acos" {
                   cellImage = UIImage(named: "acos")
               }
               if title == "1" {
                   cellImage = UIImage(named: "1")
               }
               if title == "2" {
                   cellImage = UIImage(named: "2")
               }
               if title == "3" {
                   cellImage = UIImage(named: "3")
               }
               if title == "−" {
                   cellImage = UIImage(named: "−")
               }
               if title == "atan" {
                   cellImage = UIImage(named: "atan")
               }
               if title == "S<=>D" {
                   cellImage = UIImage(named: "S<=>D")
               }
               if title == "0" {
                   cellImage = UIImage(named: "0")
               }
               if title == "." {
                   cellImage = UIImage(named: "dot")
               }
               if title == "=" {
                   cellImage = UIImage(named: "=")
               }
               if title == "+" {
                   cellImage = UIImage(named: "+")
               }
           } else {
               print("Button has no title")
           }
       }
     func setDimmedImageName(_ button: UIButton, _ cellImage: inout UIImage?) {
           if let title = button.currentTitle {
               if title == "nCr" {
                   cellImage = UIImage(named: "dnCr")
               }
               if title == "log10" {
                   cellImage = UIImage(named: "dlog10")
               }
               if title == "(" {
                   cellImage = UIImage(named: "d(")
               }
               if title == ")" {
                   cellImage = UIImage(named: "d)")
               }
               if title == "," {
                   cellImage = UIImage(named: "d,")
               }
               if title == "e^x" {
                   cellImage = UIImage(named: "de^x")
               }
               if title == "x²" {
                   cellImage = UIImage(named: "dx²")
               }
               if title == "√" {
                   cellImage = UIImage(named: "d√")
               }
               if title == "x^y" {
                   cellImage = UIImage(named: "dx^y")
               }
               if title == "n!" {
                   cellImage = UIImage(named: "dn!")
               }
               if title == "nPr" {
                   cellImage = UIImage(named: "dnPr")
               }
               if title == "y√x" {
                   cellImage = UIImage(named: "dy√x")
               }
               if title == "π" {
                   cellImage = UIImage(named: "dπ")
               }
               if title == "e" {
                   cellImage = UIImage(named: "de")
               }
               if title == "|x|" {
                   cellImage = UIImage(named: "d|x|")
               }
               if title == "AC" {
                   cellImage = UIImage(named: "dAC")
               }
               if title == "DEL" {
                   cellImage = UIImage(named: "dDEL")
               }
               if title == "sin" {
                   cellImage = UIImage(named: "dsin")
               }
               if title == "log10" {
                   cellImage = UIImage(named: "dlog10")
               }
               if title == "cos" {
                   cellImage = UIImage(named: "dcos")
               }
               if title == "7" {
                   cellImage = UIImage(named: "d7")
               }
               if title == "8" {
                   cellImage = UIImage(named: "d8")
               }
               if title == "9" {
                   cellImage = UIImage(named: "d9")
               }
               if title == "/" {
                   cellImage = UIImage(named: "ddivide")
               }
               if title == "tan" {
                   cellImage = UIImage(named: "dtan")
               }
               if title == "ln" {
                   cellImage = UIImage(named: "dln")
               }
               if title == "4" {
                   cellImage = UIImage(named: "d4")
               }
               if title == "5" {
                   cellImage = UIImage(named: "d5")
               }
               if title == "6" {
                   cellImage = UIImage(named: "d6")
               }
               if title == "×" {
                   cellImage = UIImage(named: "d×")
               }
               if title == "asin" {
                   cellImage = UIImage(named: "dasin")
               }
               if title == "acos" {
                   cellImage = UIImage(named: "dacos")
               }
               if title == "1" {
                   cellImage = UIImage(named: "d1")
               }
               if title == "2" {
                   cellImage = UIImage(named: "d2")
               }
               if title == "3" {
                   cellImage = UIImage(named: "d3")
               }
               if title == "−" {
                   cellImage = UIImage(named: "d−")
               }
               if title == "atan" {
                   cellImage = UIImage(named: "datan")
               }
               if title == "S<=>D" {
                   cellImage = UIImage(named: "dS<=>D")
               }
               if title == "0" {
                   cellImage = UIImage(named: "d0")
               }
               if title == "." {
                   cellImage = UIImage(named: "ddot")
               }
               if title == "=" {
                   cellImage = UIImage(named: "d=")
               }
               if title == "+" {
                   cellImage = UIImage(named: "d+")
               }
           } else {
               print("Button has no title")
           }
       }
}
