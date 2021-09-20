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
        button.backgroundColor = .primaryColor
        button.setTitle("Record", for: .normal)
        return button
    }()
    
    fileprivate lazy var playButton: BrandButton = {
        let button = BrandButton()
        button.backgroundColor = .lightPrimaryColor
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


    override func loadView() {
        view = UIView()
        view.backgroundColor = .backgroundColor
        safeArea = view.safeAreaLayoutGuide
        setupFonts()
        addViews()
        addActions()
    }
    
    func addViews() {
        addButtonsStackView()
        addTitleLabel()
        addTextView()
    }
    
    func addActions() {
        playButton.addTarget(self, action: #selector(playButtonDidTap(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonDidTap(_:)), for: .touchUpInside)
    }
}

//MARK: - Actions
extension ViewController {
    @objc func playButtonDidTap(_ sender: UIButton) {
        
    }
    
    @objc func recordButtonDidTap(_ sender: UIButton) {
        
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
