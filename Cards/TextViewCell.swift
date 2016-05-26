//
//  TextViewCell.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit
import FLTextView

protocol DynamicHeightCell {
    func heightForCellAtIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat
}


class TextViewCell: UITableViewCell {
    
    @IBOutlet weak var clearButton: ClearButton!
    @IBOutlet weak var textView: FLTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // MARK: - Toolbar
    
    lazy var toolbar: Toolbar = {
        let instance = Toolbar()
        weak var weakSelf = self
        instance.jumpToPrevious = {
            if let cell = weakSelf {
                cell.gotoPrevious()
            }
        }
        instance.jumpToNext = {
            if let cell = weakSelf {
                cell.gotoNext()
            }
        }
        instance.dismissKeyboard = {
            if let cell = weakSelf {
                cell.dismissKeyboard()
            }
        }
        return instance
    }()
    
    func updateToolbarButtons() {
        toolbar.updateButtonConfiguration(self)
    }
    
    func gotoPrevious() {
        makePreviousCellFirstResponder()
    }
    
    func gotoNext() {
        makeNextCellFirstResponder()
    }
    
    func dismissKeyboard() {
        resignFirstResponder()
    }
    
    
    // MARK: - Actions
    
    @IBAction func clearTextView(sender: UIButton) {
        textView.text = ""
        updateValue()
    }
    
    
    // MARK: - Table update
    
    func updateValue() {
        tableView!.beginUpdates()
        tableView!.endUpdates()
    }
    
    func calculateHeightForCell(cell: TextViewCell) -> CGFloat {
        cell.clearButton.hidden = !textView.hasText()
        
        let textViewWidth = cell.textView.frame.size.width
        let size = cell.textView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max))
        return size.height + 10
    }
    
    // MARK: UIResponder
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
    
    
    func scrollToVisibleRect() {
        guard let tableView = tableView else { return }
        guard let indexPath = tableView.indexPathForCell(self) else { return }
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
}


// MARK: - UITextViewDelegate

extension TextViewCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.inputAccessoryView = toolbar
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        updateToolbarButtons()
    }
    
    func textViewDidChange(textView: UITextView) {
        updateValue()
        
        let range = NSMakeRange(textView.text.characters.count, 0)
        textView.scrollRangeToVisible(range)
        
        scrollToVisibleRect()
    }
}


extension TextViewCell: DynamicHeightCell {
    
    func heightForCellAtIndexPath(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
        let height = calculateHeightForCell(self)
        return height
    }
    
}
