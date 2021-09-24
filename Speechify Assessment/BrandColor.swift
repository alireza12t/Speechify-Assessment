//
//  UIColorExtension.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/21/21.
//

import UIKit

enum BrandColor: String {
    case backgroundColor, lightPrimaryColor, primaryColor, textColor
    
    var color: UIColor {
        return UIColor(named: self.rawValue)!
    }
}
