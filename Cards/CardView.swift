//
//  CardView.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/26/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var stackView: UIStackView!
    var label: UILabel!
    var frontText: String!
    var backText: String!

    var isBack = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.textAlignment = .Center
        label.layer.cornerRadius = 10.0
        label.font = .boldSystemFontOfSize(32)
        
        backgroundColor = .whiteColor()
        
        addSubview(label)
        
        // Shadow
        layer.borderWidth = 0.5
        layer.shadowRadius = 6.0
        layer.cornerRadius = 10.0
        layer.shadowOpacity = 0.25
        layer.shouldRasterize = true
        layer.shadowOffset = CGSizeMake(2, 2)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.text = isBack ? backText : frontText
    }
    
}
