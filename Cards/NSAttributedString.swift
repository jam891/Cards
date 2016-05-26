//
//  NSAttributedString.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    convenience init?(string text: String?, font: UIFont!, color: UIColor!) {
        self.init(string: text!, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
    }
    
    convenience init?(string text: String?, font: UIFont!) {
        self.init(string: text!, attributes: [NSFontAttributeName: font])
    }
}