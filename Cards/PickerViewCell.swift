//
//  PickerViewCell.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class PickerViewCell: UITableViewCell {
    
    @IBOutlet var textField: UITextField!
    
    private let pickerOption = [
        "unknown",
        "noun",
        "pronoun",
        "adjective",
        "numeral",
        "infinitive",
        "verb",
        "participle",
        "gerund",
        "adverb",
        "conjunction",
        "particle",
        "interjection",
        "preposition"
    ]
    
    
    
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
    
    func done() {
        endEditing(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField.inputView = pickerView
    }
    
    
    // MARK: UIResponder
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
}


// MARK: - UITextFieldDelegate

extension PickerViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.inputAccessoryView = toolbar
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        updateToolbarButtons()
        
    }
    
}


// MARK: - UIPickerViewDataSource

extension PickerViewCell: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOption.count
    }
}


// MARK: - UIPickerViewDelegate

extension PickerViewCell: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOption[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            textField.text = ""
            return
        }
        textField.text = pickerOption[row]
    }
}
