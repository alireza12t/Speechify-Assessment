//
//  ViewController.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/21/21.
//

import UIKit

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
    
    var viewModel = ViewModel()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = BrandColor.backgroundColor.color
        safeArea = view.safeAreaLayoutGuide
        setupFonts()
        addViews()
        addActions()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.requestAuthorization()
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

//MARK: - Actions
extension ViewController {
    @objc func playButtonDidTap(_ sender: UIButton) {
        viewModel.playSound()
    }
    
    @objc func recordButtonDidTap(_ sender: UIButton) {
        viewModel.startStopRecord()
    }
}

//MARK: - Make UI and Setup UI
extension ViewController {
    func addButtonsStackView() {
        viewModel.playButton = playButton
        viewModel.recordButton = recordButton
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
        viewModel.titleLabel = titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: safeArea, attribute: .leading, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: safeArea, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: safeArea, attribute: .top, multiplier: 1, constant: topSpace)
        ])
    }
    
    func addErrorLabel() {
        viewModel.errorLabel = errorLabel
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorLabel, attribute: .leading, relatedBy: .equal, toItem: stackView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .trailing, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .top, multiplier: 1, constant: -20)
        ])
    }
    
    func addTextView() {
        viewModel.textView = textView
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
