//
//  SSNTextField.swift
//  IOSW1
//
//  Created by Mauricio Jacobo Romero on 26/09/2016.
//  Copyright © 2016 MJ. All rights reserved.
//

import Foundation
import UIKit

class SSNTextField: UITextField {
    var formattingPattern = "***-**-***-****-*"
    var replacementChar: Character = "*"
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        registerForNotifications()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SSNTextField.textDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func makeOnlyDigitsString(string: String) -> String {
        let stringArray = string.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        return newString
    }
    
    
    func textDidChange() {
        if self.text!.characters.count > 0 && self.formattingPattern.characters.count > 0 {
            let tempString = makeOnlyDigitsString(string: self.text!)
            
            var finalText = ""
            var stop = false
            
            var formatterIndex = formattingPattern.startIndex
            var tempIndex = tempString.startIndex
            
            while !stop {
                let formattingPatternRange = Range(uncheckedBounds: (lower: formatterIndex, upper: formattingPattern.index(after: formatterIndex)))
                if formattingPattern.substring(with: formattingPatternRange) != String(replacementChar)
                {
                    finalText = finalText + formattingPattern.substring(with: formattingPatternRange)
                } else if tempString.characters.count > 0 {
                    let pureStringRange = Range(uncheckedBounds: (lower: tempIndex, upper: tempString.index(after:tempIndex)))
                    finalText = finalText +  tempString.substring(with: pureStringRange)
                    tempIndex = tempString.index(after:tempIndex)
                }
                formatterIndex = formattingPattern.index(after: formatterIndex)
                if formatterIndex >= formattingPattern.endIndex || tempIndex >= tempString.endIndex {
                    stop = true
                }
            }
            
            self.text = finalText
        }
    }
}
