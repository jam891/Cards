//
//  DeckEditTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class DeckEditTableViewController: UITableViewController {
    
    typealias DidFailureDelegate = (title: String, message: String) -> Void
    typealias DidFinishDelegate = (deck: Deck) -> Void
    typealias DidDeleteDelegate = (deck: Deck) -> Void
    var didFailure: DidFailureDelegate?
    var didFinish: DidFinishDelegate?
    var didDelete: DidDeleteDelegate?
    
    var deck: Deck!
    
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
        nameTextField.text = deck.name
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let name = nameTextField.text!.trim()
        
        if deck.name == name || deck.updated {
            return
        }
        
        if name.characters.count == 0 {
            didFailure?(title: NSLocalizedString("Please choose another name", comment: ""),
                        message: NSLocalizedString("Sorry, names must be at least 1 character in length.", comment: ""))
        } else if validate(name) {
            didFailure?(title: NSLocalizedString("Please choose another name", comment: ""),
                        message: NSLocalizedString("You already have a deck named '\(name)'", comment: ""))
        } else {
            deck.name = name
            didFinish!(deck: deck)
        }
    }
    
    
    func validate(name: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", name)
        let result = cardsModel.get(withPredicate: predicate)
        return name == result.first?.name
    }
   
    
    // MARK: - Actions
    
    @IBAction func deleteDeck(sender: UIButton) {
        view.endEditing(true)
        showAlert()
    }
    
    
    // MARK: - Alert
    
    func showAlert() {
        let title = NSLocalizedString("Are you sure you want to delete the deck '\(deck.name!)'?", comment: "")
        let message = NSLocalizedString("Any cards in this deck will be moved to the Trash. This operation cannot be undone.", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Default) { action in
            self.didDelete!(deck: self.deck)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cardsModel.getAll().count == 1 ? 1 : 2
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? NSLocalizedString("\(deck.cards!.count) Cards", comment: "") : nil
    }

}
