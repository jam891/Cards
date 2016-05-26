//
//  CardAddTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class CardAddTableViewController: UITableViewController {
    
    @IBOutlet weak var frontTextCell: TextViewCell!
    @IBOutlet weak var transcriptionCell: TextViewCell!
    @IBOutlet weak var partOfSpeechCell: PickerViewCell!
    @IBOutlet weak var backTextCell: TextViewCell!
    @IBOutlet weak var examplesCell: TextViewCell!
    
    typealias DidFinishDelegate = (frontText: String, backText: String, transcription: String, partOfSpeech: String, examples: String) -> ()
    var didFinish: DidFinishDelegate?
    
    var deck: Deck!
    
    private var errorLabel: UILabel!

    var cells = [UITableViewCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        cells.append(frontTextCell)
        cells.append(transcriptionCell)
        cells.append(partOfSpeechCell)
        cells.append(backTextCell)
        cells.append(examplesCell)

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(CardAddTableViewController.dismissKeyboard(_:)))
        view.addGestureRecognizer(dismissTap)
    }
    
    
    // MARK: - Dismiss Keyboard
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    // MARK: - Actions
    
    @IBAction func create(sender: UIBarButtonItem) {
        
        let frontText = frontTextCell.textView.text!.trim()
        
        if frontText.characters.count == 0 {
            errorLabel.text = NSLocalizedString("Words must contain at least 1 character.", comment: "")
            animate()
        } else if validate(frontText) {
            errorLabel.text = NSLocalizedString("Words must be unique.", comment: "")
            animate()
        } else {
            didFinish!(frontText: frontText,
                       backText: backTextCell.textView.text!.trim(),
                       transcription: transcriptionCell.textView.text!.trim(),
                       partOfSpeech: partOfSpeechCell.textField.text!.trim(),
                       examples: examplesCell.textView.text!.trim()
            )
        }
    }

    
    
    // MARK: - Validation
    
    func validate(frontText: String) -> Bool {
        let predicate = NSPredicate(format: "%K == %@", "deck", deck)
        let result = deck.get(withPredicate: predicate)
        return frontText == result.first?.frontText
    }
    
    
    // MARK: - Animate Error Label
    
    func animate() {
        errorLabel.alpha = 0
        UIView.animateWithDuration(0.7) {
            self.errorLabel.alpha = 1
        }
    }


    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cell = cells[indexPath.section] as? DynamicHeightCell {
            return cell.heightForCellAtIndexPath(indexPath, tableView: tableView)
        }
        return 50
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            errorLabel = UILabel()
            errorLabel.numberOfLines = 0
            errorLabel.textColor = .redColor()
            errorLabel.textAlignment = .Center
            errorLabel.adjustsFontSizeToFitWidth = true
            return errorLabel
        }
        return nil
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    // hide keyboard when the user starts scrolling
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.firstResponder()?.resignFirstResponder()
    }
    
    // hide keyboard when the user taps the status bar
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        scrollView.firstResponder()?.resignFirstResponder()
        return true
    }

    
}
