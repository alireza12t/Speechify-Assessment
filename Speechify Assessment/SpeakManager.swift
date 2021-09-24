//
//  SpeakManager.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/24/21.
//

import AVFoundation

class SpeakManager {
    
    static var shared = SpeakManager()
        
    func say(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.45

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
