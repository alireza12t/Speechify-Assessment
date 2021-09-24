//
//  ViewModel.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/24/21.
//

import UIKit
import Speech

class ViewModel: NSObject {
    
    weak var textView: UITextView?
    weak var titleLabel: UILabel?
    weak var errorLabel: UILabel?
    weak var playButton: BrandButton?
    weak var recordButton: BrandButton?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var audioPlayer: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    
    var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    override init() {
        super.init()
        speechRecognizer.delegate = self
    }
    
    private func startConvertingSpeech() throws {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        try audioSession.setCategory(.playAndRecord, mode: .default, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            AlertManager.showAlert(withTitle: "Error!", withMessage: "Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            stopConvertingSpeech()
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                let newTranscriptionText = result.bestTranscription.formattedString
                var oldTranscriptionText = self.textView?.text ?? ""
                if oldTranscriptionText == "I'm listening" {
                    oldTranscriptionText = ""
                }
                
                let newWordsList = newTranscriptionText.split(separator: " ").compactMap({String($0)})
                let lastOldWord = oldTranscriptionText.split(separator: " ").compactMap({String($0)}).last ?? ""
                
                if let difference = newWordsList.last, !difference.contains(lastOldWord), newTranscriptionText != oldTranscriptionText {
                    self.textView?.attributedText = newWordsList.dropLast().joined(separator: " ").generateAttributedString(highlightedText: difference)
                } else {
                    self.textView?.attributedText = newTranscriptionText.generateAttributedString(highlightedText: "")
                }
                self.textView?.textColor = BrandColor.textColor.color
                isFinal = result.isFinal
                print("New Text => \(newTranscriptionText)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton?.setTitle("Start Recording", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        textView?.text = ""
        textView?.text = "I'm listening"
        textView?.textColor = .systemGray
    }
    
    private func stopConvertingSpeech() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    func startStopRecord() {
        if audioEngine.isRunning {
            stopConvertingSpeech()
        } else {
            do {
                try startConvertingSpeech()
                recordButton?.setTitle("Stop recording", for: [])
            } catch(let recordError) {
                AlertManager.showAlert(withTitle: "Error!", withMessage: "\(recordError)")
            }
        }
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton?.isEnabled = true
                    self.errorLabel?.text = ""
                case .denied:
                    self.recordButton?.isEnabled = false
                    self.errorLabel?.text = "User denied access to speech recognition"
                case .restricted:
                    self.recordButton?.isEnabled = false
                    self.errorLabel?.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.recordButton?.isEnabled = false
                    self.errorLabel?.text = "Speech recognition not yet authorized"
                default:
                    self.errorLabel?.text = "Unknown error!"
                    self.recordButton?.isEnabled = false
                }
            }
        }
    }
    
    func playSound() {
    //        if audioPlayer != nil {
    //            if audioPlayer!.isPlaying {
    //                audioPlayer?.pause()
    //            } else {
    //                audioPlayer?.play()
    //            }
    //        } else {
    //            do {
    //                let audioPlayer = try AVAudioPlayer(contentsOf: audioRecorder.url)
    //                audioPlayer.play()
    //            } catch let error {
    //                AlertManager.showAlert(withTitle: "Error in playing!", withMessage: "Can't play the audio file failed with an error \(error.localizedDescription)")
    //            }
    //        }
            //MARK: I need to fix recoriding sound and play it here but it has a bug and I couldn't find the problem and submmited my question in stackoverflow => https://stackoverflow.com/questions/69318638/record-voice-while-converting-speech-to-text-using-sfspeechrecognitiontask
            if let text = textView?.text, !text.isEmpty {
                SpeakManager.shared.say(text)
            } else {
                AlertManager.showAlert(withTitle: "Error in playing!", withMessage: "You didn't say anything!", withOkButtonTitle: "OK")
            }
        }
}

extension ViewModel: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton?.isEnabled = true
            errorLabel?.text = ""
        } else {
            recordButton?.isEnabled = false
            errorLabel?.text = "Recognition Not Available"
        }
    }
}
