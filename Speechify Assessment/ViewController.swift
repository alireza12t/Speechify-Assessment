//
//  ViewController.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/21/21.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    fileprivate lazy var recordButton: BrandButton = {
        let button = BrandButton()
        button.originalBackgroundColor = BrandColor.primaryColor.color
        button.setTitle("Record", for: [])
        button.accessibilityLabel = "Record"
        button.accessibilityHint = "this button can start or stop recording"
        return button
    }()
    
    fileprivate lazy var playButton: BrandButton = {
        let button = BrandButton()
        button.originalBackgroundColor = BrandColor.lightPrimaryColor.color
        button.setTitle("Play", for: [])
        button.accessibilityLabel = "Play"
        button.accessibilityHint = "this button can play recorded voice"
        return button
    }()
    
    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [recordButton, playButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.textAlignment = .center
        label.text = "1. Record, 2. View Transcribed text, 3. Play back audio with text highlighting."
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.textAlignment = .center
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.accessibilityLabel = "speech"
        textView.accessibilityHint = "this textview shows text that made with your speech"
        return textView
    }()
    
    var safeArea = UILayoutGuide()
    var topSpace: CGFloat = 60
    var bottomSpace: CGFloat = 35
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var audioPlayer: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = BrandColor.backgroundColor.color
        safeArea = view.safeAreaLayoutGuide
        setupFonts()
        addViews()
        addActions()
        speechRecognizer.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAuthorization()
    }
    
    func addViews() {
        addButtonsStackView()
        addTitleLabel()
        addTextView()
        addErrorLabel()
    }
    
    func addActions() {
        playButton.addTarget(self, action: #selector(playButtonDidTap(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonDidTap(_:)), for: .touchUpInside)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

//MARK: - SpeechRecognizerDelegate
extension ViewController: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            errorLabel.text = ""
        } else {
            recordButton.isEnabled = false
            errorLabel.text = "Recognition Not Available"
        }
    }
}

//MARK: - Speech Convertor & Record
extension ViewController {
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
            AlertManager.showAlert(withTitle: "Error!", withMessage: "Unable to create a SFSpeechAudioBufferRecognitionRequest object", withOkButtonTitle: "OK", on: self)
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
                var oldTranscriptionText = self.textView.text ?? ""
                if oldTranscriptionText == "I'm listening" {
                    oldTranscriptionText = ""
                }
                
                let newWordsList = newTranscriptionText.split(separator: " ").compactMap({String($0)})
                let lastOldWord = oldTranscriptionText.split(separator: " ").compactMap({String($0)}).last ?? ""
                
                if let difference = newWordsList.last, !difference.contains(lastOldWord), newTranscriptionText != oldTranscriptionText {
                    self.textView.attributedText = newWordsList.dropLast().joined(separator: " ").generateAttributedString(highlightedText: difference)
                } else {
                    self.textView.attributedText = newTranscriptionText.generateAttributedString(highlightedText: "")
                }
                self.textView.textColor = BrandColor.textColor.color
                isFinal = result.isFinal
                print("New Text => \(newTranscriptionText)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.setTitle("Start Recording", for: [])
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
        textView.text = ""
        textView.text = "I'm listening"
        textView.textColor = .systemGray
    }
    
    func stopConvertingSpeech() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

//MARK: - Authorizations
extension ViewController {
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    self.errorLabel.text = ""
                case .denied:
                    self.recordButton.isEnabled = false
                    self.errorLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.errorLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.errorLabel.text = "Speech recognition not yet authorized"
                default:
                    self.errorLabel.text = "Unknown error!"
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
}

//MARK: - Actions
extension ViewController {
    @objc func playButtonDidTap(_ sender: UIButton) {
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
//                AlertManager.showAlert(withTitle: "Error in playing!", withMessage: "Can't play the audio file failed with an error \(error.localizedDescription)", withOkButtonTitle: "OK", on: self)
//            }
//        }
        //MARK: I need to fix recoriding sound and play it here but it has a bug and I couldn't find the problem and submmited my question in stackoverflow => https://stackoverflow.com/questions/69318638/record-voice-while-converting-speech-to-text-using-sfspeechrecognitiontask
        if let text = textView.text, !text.isEmpty {
            SpeakManager.shared.say(text)
        } else {
            SpeakManager.shared.say("You didn't say anything!")
            AlertManager.showAlert(withTitle: "Error in playing!", withMessage: "You didn't say anything!", withOkButtonTitle: "OK", on: self)
        }
    }
    
    @objc func recordButtonDidTap(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopConvertingSpeech()
        } else {
            do {
                try startConvertingSpeech()
                recordButton.setTitle("Stop recording", for: [])
            } catch(let recordError) {
                AlertManager.showAlert(withTitle: "Error!", withMessage: "\(recordError)", withOkButtonTitle: "OK", on: self)
            }
        }
    }
}

//MARK: - Make UI and Setup UI
extension ViewController {
    func addButtonsStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: safeArea, attribute: .trailing, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: safeArea, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .bottom, multiplier: 1, constant: bottomSpace),
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 60)
        ])
    }
    
    func addTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: safeArea, attribute: .leading, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: safeArea, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: safeArea, attribute: .top, multiplier: 1, constant: topSpace)
        ])
    }
    
    func addErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorLabel, attribute: .leading, relatedBy: .equal, toItem: stackView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .trailing, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .top, multiplier: 1, constant: -20)
        ])
    }
    
    func addTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: stackView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 240)
        ])
    }
    
    func setupFonts() {
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        textView.font = .boldSystemFont(ofSize: 15)
        playButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        recordButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    }
}
