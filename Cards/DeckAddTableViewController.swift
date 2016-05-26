//
//  DeckAddTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class DeckAddTableViewController: UITableViewController {
    
    typealias DidFinishDelegate = (name: String) -> Void
    var didFinish: DidFinishDelegate?

    @IBOutlet weak var nameTextField: UITextField!
    
    private var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
    }

    
    // MARK: - Actions
    
    @IBAction func done(sender: UIBarButtonItem) {
        let name = nameTextField.text!.trim()
        
        if name.characters.count == 0 {
            errorLabel.text = NSLocalizedString("Deck names must contain at least 1 character.", comment: "")
            animate()
        } else if validate(name) {
            errorLabel.text = NSLocalizedString("Names must be unique.", comment: "")
            animate()
        } else {
            didFinish?(name: name)
        }
    }
    
    
    func validate(name: String) -> Bool {
        let predicate = NSPredicate(format: "name == %@", name)
        let result = cardsModel.get(withPredicate: predicate)
        return name == result.first?.name
    }
    
    
    func animate() {
        errorLabel.alpha = 0
        UIView.animateWithDuration(0.7) {
            self.errorLabel.alpha = 1
        }
    }
    

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        errorLabel = UILabel()
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .redColor()
        errorLabel.textAlignment = .Center
        errorLabel.adjustsFontSizeToFitWidth = true
        return errorLabel
    }

}
