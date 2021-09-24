//
//  Button.swift
//  Speechify Assessment
//
//  Created by Alireza on 9/21/21.
//

import UIKit

public class BrandButton: UIButton {
        
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public func setupUI() {
        layer.cornerRadius = self.cornerRadius
        originalBackgroundColor = backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        setTitleColor(.white, for: .normal)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        shrink()
        lightVibrate()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        restore()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        restore()
    }
    
    func shrink() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self?.layoutIfNeeded()
        }
    }
    
    func restore() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.layoutIfNeeded()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 30 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var originalBackgroundColor: UIColor? = .primaryColor {
        didSet {
            if isEnabled {
                self.backgroundColor = originalBackgroundColor
            }
        }
    }
}

extension BrandButton {
    public override var isEnabled: Bool {
        didSet {
            if isEnabled {
                self.backgroundColor = originalBackgroundColor
            } else {
                self.backgroundColor = .systemGray
            }
        }
    }
}
