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
        button.setTitle("Record", for: .normal)
        return button
    }()
    
    fileprivate lazy var playButton: BrandButton = {
        let button = BrandButton()
        button.originalBackgroundColor = BrandColor.lightPrimaryColor.color
        button.setTitle("Play", for: .normal)
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
        return textView
    }()
    
    var safeArea = UILayoutGuide()
    var topSpace: CGFloat = 60
    var bottomSpace: CGFloat = 35
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
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
    private func startRecording() throws {
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            AlertManager.showAlert(withTitle: "Error!", withMessage: "Unable to create a SFSpeechAudioBufferRecognitionRequest object", withOkButtonTitle: "OK", on: self)
            stopRecording()
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
                self.textView.text = result.bestTranscription.formattedString
                textView.textColor = BrandColor.textColor.color
                isFinal = result.isFinal
                print("Text => \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
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
        textView.text = "I'm listening"
        textView.textColor = .systemGray
    }
    
    func stopRecording() {
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
        
    }
    
    @objc func recordButtonDidTap(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            do {
                try startRecording()
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
