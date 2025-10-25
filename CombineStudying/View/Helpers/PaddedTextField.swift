//
//  PaddedTextField.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import UIKit

final class PaddedTextField: UITextField{
    let edges = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: edges)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: edges)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: edges)
    }
}
