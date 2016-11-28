//
//  CircleButton.swift
//  VoiceRecognition
//
//  Created by Emmanuel Erilibe on 11/27/16.
//  Copyright © 2016 Emmanuel Erilibe. All rights reserved.
//

import UIKit
@IBDesignable

class CircleButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet {
            setupView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = cornerRadius
    }

}
