//
//  Extension.swift
//  EazySplit
//
//  Created by Dynara Rico Oliveira on 21/04/19.
//  Copyright © 2019 Dynara Rico Oliveira. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(withURL: String) {
        guard let withURL = URL(string: withURL) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: withURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
    
    func loadImage(withURL: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: withURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}

extension UIButton {
    func loadCornerRadius() {
        self.layer.cornerRadius = 5
    }
}

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = ValidatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
    
    func showMessage(_ text: String) {
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 0.5
        attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
}

extension String {
    var removeCharsFromStringPhone: String {
        let okayChars = Set("1234567890+")
        return self.filter {okayChars.contains($0) }
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        
        return pureNumber
    }
    
    func replicate(withNumber number: Int) -> String {
        var replicateString = ""
        for i in 0..<number {
            replicateString += self
        }
        return replicateString
    }
}
