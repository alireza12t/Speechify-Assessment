//
//  GlobalFunctions.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/21/21.
//

import UIKit

func lightVibrate() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

func softVibrate() {
    if #available(iOS 13.0, *) {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    } else {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
