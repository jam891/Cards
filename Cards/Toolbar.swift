//
//  Toolbar.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class Toolbar: UIToolbar {
    
    var jumpToPrevious: Void -> Void = {}
    var jumpToNext: Void -> Void = {}
    var dismissKeyboard: Void -> Void = {}
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .whiteColor()
        items = toolbarItems()
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleBottomMargin, .FlexibleTopMargin]
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var previousButton: UIBarButtonItem = {
        let image = UIImage(named: "ArrowLeft")!
        image.imageWithRenderingMode(.AlwaysTemplate)
        return UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(Toolbar.previousButtonAction(_:)))
    }()
    
    lazy var nextButton: UIBarButtonItem = {
        let image = UIImage(named: "ArrowRight")!
        image.imageWithRenderingMode(.AlwaysTemplate)
        return UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(Toolbar.nextButtonAction(_:)))
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(Toolbar.closeButtonAction(_:)))
        return item
    }()
    
    func toolbarItems() -> [UIBarButtonItem] {
        let spacer0 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        spacer0.width = 15.0
        
        let spacer1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        var items = [UIBarButtonItem]()
        items.append(previousButton)
        items.append(spacer0)
        items.append(nextButton)
        items.append(spacer1)
        items.append(closeButton)
        return items
    }
    
    func previousButtonAction(sender: UIBarButtonItem!) {
        jumpToPrevious()
    }
    
    func nextButtonAction(sender: UIBarButtonItem!) {
        jumpToNext()
    }
    
    func closeButtonAction(sender: UIBarButtonItem!) {
        dismissKeyboard()
    }
    
    func updateButtonConfiguration(cell: UITableViewCell) {
        previousButton.enabled = cell.canMakePreviousCellFirstResponder()
        nextButton.enabled = cell.canMakeNextCellFirstResponder()
    }
}

