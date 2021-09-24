//
//  StringExtension.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/24/21.
//

import UIKit

extension String {
    func generateAttributedString(highlightedText: String, highlightColor: UIColor = BrandColor.highlightColor.color) -> NSAttributedString? {
        var fullText: String!
        var range: NSRange!
        
        if self.isEmpty {
            fullText = [highlightedText].joined(separator: " ")
            range = NSRange(location: self.count, length: highlightedText.count)
        } else {
            fullText = ([self, highlightedText]).joined(separator: " ")
            range = NSRange(location: self.count + 1, length: highlightedText.count)
        }
        let attributedString = NSMutableAttributedString(string: fullText)
                
//        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold), range: range)
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: highlightColor, range: range)
        
        return attributedString
    }
}
