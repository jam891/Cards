//
//  CardEditTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class CardEditTableViewController: UITableViewController {
    
    @IBOutlet weak var frontTextCell: TextViewCell!
    @IBOutlet weak var transcriptionCell: TextViewCell!
    @IBOutlet weak var partOfSpeechCell: PickerViewCell!
    @IBOutlet weak var backTextCell: TextViewCell!
    @IBOutlet weak var examplesCell: TextViewCell!
    @IBOutlet weak var deleteCardCell: UITableViewCell!
    
    typealias DidFailureDelegate = (title: String, message: String) -> Void
    typealias DidFinishDelegate = (card: Card) -> Void
    typealias DidDeleteDelegate = (card: Card) -> Void
    var didFailure: DidFailureDelegate?
    var didFinish: DidFinishDelegate?
    var didDelete: DidDeleteDelegate?
    
    var deck: Deck!
    var card: Card!
    
    var cells = [UITableViewCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cells.append(frontTextCell)
        cells.append(transcriptionCell)
        cells.append(partOfSpeechCell)
        cells.append(backTextCell)
        cells.append(examplesCell)
        cells.append(deleteCardCell)
        
        frontTextCell.textView.text = card.frontText
        transcriptionCell.textView.text = card.transcription
        partOfSpeechCell.textField.text = card.partOfSpeech
        backTextCell.textView.text = card.backText
        examplesCell.textView.text = card.examples
        
        frontTextCell.textView.becomeFirstResponder()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(dismissTap)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveChange()
    }

    // MARK: - Dismiss Keyboard
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
 
    
    func saveChange() {
        let frontText = frontTextCell.textView.text!.trim()
       
        if frontText.characters.count == 0 {
            didFailure?(title: NSLocalizedString("Please choose another name", comment: ""),
                        message: NSLocalizedString("Sorry, names must be at least 1 character in length.", comment: ""))
            
        } else if frontText != card.frontText && validate(frontText) {
            didFailure?(title: NSLocalizedString("Please choose another name", comment: ""),
                        message: NSLocalizedString("You already have a card named '\(frontText.trim())'", comment: ""))
        } else {
            card.frontText = frontText.trim()
            card.transcription = transcriptionCell.textView.text!.trim()
            card.partOfSpeech = partOfSpeechCell.textField.text!.trim()
            card.backText = backTextCell.textView.text!.trim()
            card.examples = examplesCell.textView.text!.trim()
            didFinish!(card: card)
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func deleteCard(sender: UIButton) {
        showActionSheet()
    }
    
    
    // MARK: - Alert
    
    func showActionSheet() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Destructive, handler: { alert in
            self.didDelete!(card: self.card)
            self.navigationController?.popViewControllerAnimated(true)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    // MARK: - Validation
    
    func validate(frontText: String) -> Bool {
        let predicate = NSPredicate(format: "%K == %@", "deck", deck)
        let result = deck.get(withPredicate: predicate)
        return frontText == result.first?.frontText
    }
    



    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cell = cells[indexPath.section] as? DynamicHeightCell {
            return cell.heightForCellAtIndexPath(indexPath, tableView: tableView)
        }
        return 50
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
