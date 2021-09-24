//
//  AlertManager.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/24/21.
//

import Foundation
import UIKit

class AlertManager {
    
    class func showAlert(withTitle title: String, withMessage message: String, withOkButtonTitle buttonTitle: String, on viewcontroller: UIViewController) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        viewcontroller.present(alertView, animated: true, completion: nil)
    }
}
