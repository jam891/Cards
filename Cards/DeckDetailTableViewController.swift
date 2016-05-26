//
//  DeckDetailTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class DeckDetailTableViewController: UIViewController {
    
    static let nibName = "CardTableViewCell"
    static let cellIdentifier = "Card"
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    var resultsController: UITableViewController!
    var searchController: UISearchController!
    
    var deck: Deck!
    var cards: [Card]!
    var filteredCards: [Card]!
    var selectedCard: Card!
    var searchText: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cards = []
        filteredCards = []
    
        initializeFetchedResultsController()
        
        let nib = UINib(nibName: DeckDetailTableViewController.nibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: DeckDetailTableViewController.cellIdentifier)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        resultsController = UITableViewController(style: .Grouped)
        resultsController.tableView.registerNib(nib, forCellReuseIdentifier: DeckDetailTableViewController.cellIdentifier)
        resultsController.tableView.rowHeight = 50.0
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.emptyDataSetSource = self
        resultsController.tableView.emptyDataSetDelegate = self
    }
 
    
    // MARK: - Initialize fetched results controller
    
    func initializeFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: Card.EntityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "deck", deck)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cardsModel.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            cards = fetchedResultsController.fetchedObjects as! [Card]
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    
    // MARK: - Initialize search controller
    
    func configureSearchController() {
        let nib = UINib(nibName: DeckDetailTableViewController.nibName, bundle: nil)
        resultsController = UITableViewController(style: .Grouped)
        resultsController.tableView.registerNib(nib, forCellReuseIdentifier: DeckDetailTableViewController.cellIdentifier)
        resultsController.tableView.rowHeight = 50.0
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.emptyDataSetSource = self
        resultsController.tableView.emptyDataSetDelegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        
        definesPresentationContext = true
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(button: UIBarButtonItem) {
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        
        definesPresentationContext = true
        presentViewController(searchController, animated: true, completion: nil)
    }


    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "CardDetail":
                let detailViewController = segue.destinationViewController as! CardDetailViewController
                var cards = deck.get(withPredicate: NSPredicate(format: "%K == %@", "deck", deck))
                cards.sortInPlace { $0.timeStamp!.compare($1.timeStamp!) == .OrderedDescending }
                detailViewController.card = selectedCard
                detailViewController.cards = cards
                detailViewController.deck = deck
            case "AddCard":
                if let navigationController = segue.destinationViewController as? UINavigationController,
                    let cardAddViewController = navigationController.viewControllers.first as? CardAddTableViewController {
                    cardAddViewController.deck = deck
                    cardAddViewController.didFinish = { frontText, backText, transcription, partOfSpeech, examples in
                        self.deck.createCard(frontText, backText: backText, transcription: transcription, partOfSpeech: partOfSpeech, examples: examples)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        cardsModel.saveContext()
                    }
                }
            case "EditCard":
                let cardEditViewController = segue.destinationViewController as! CardEditTableViewController
                cardEditViewController.deck = deck
                cardEditViewController.title = deck.name
                cardEditViewController.card = selectedCard
                cardEditViewController.didDelete = { card in self.deck.deleteCard(card.objectID) }
                cardEditViewController.didFailure = { title, message in self.showAlert(title, message: message) }
                cardEditViewController.didFinish = { card in
                    self.tableView.reloadData()
                    self.deck.update(card)
                }
            case "ShowCards":
                let showViewController = segue.destinationViewController as! ShowViewController
                var cards = deck.get(withPredicate: NSPredicate(format: "%K == %@", "deck", deck))
                cards.sortInPlace { $0.timeStamp!.compare($1.timeStamp!) == .OrderedDescending }
                showViewController.title = deck.name
                showViewController.cards = cards
            default: break
            }
        }
    }
 
    
    @IBAction func unwindToDeckDetail(sender: UIStoryboardSegue) {
    }
    
    
    // MARK: - Alert
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - View Auto-Rotation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadEmptyDataSet()
        resultsController.tableView.reloadEmptyDataSet()
    }


}


// MARK: - Table view data source

extension DeckDetailTableViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableView ? cards.count : filteredCards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DeckDetailTableViewController.cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let card = cell.tableView === self.tableView ? cards[indexPath.row] : filteredCards[indexPath.row]
        if let cell = cell as? CardTableViewCell {
            cell.textLabel!.text = card.frontText
            cell.detailTextLabel?.text = card.backText
        }
    }

}


// MARK: - Table view delegate

extension DeckDetailTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCard = tableView === self.tableView ? cards[indexPath.row] : filteredCards[indexPath.row]
        performSegueWithIdentifier("CardDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView === resultsController.tableView && filteredCards?.count != 0 ? "card" : nil
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .Normal, title: NSLocalizedString("Edit", comment: ""), handler: { action, indexPath in
            self.selectedCard = self.cards[indexPath.row]
            self.performSegueWithIdentifier("EditCard", sender: self)
        })
        
        let deleteAction = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("Delete", comment: ""), handler: { action, indexPath in
            self.selectedCard = self.cards[indexPath.row]
            self.deck.deleteCard(self.selectedCard.objectID)
        })
        editAction.backgroundColor = UIColor.lightGrayColor()
        deleteAction.backgroundColor = .redColor()
        return [deleteAction, editAction]
    }
    
//    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return false
//    }
    
//    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        let movedCard = cards[sourceIndexPath.row]
//        cards.removeAtIndex(sourceIndexPath.row)
//        cards.insert(movedCard, atIndex: destinationIndexPath.row)
//    }
//    
//    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }

}


// MARK: - NSFetchedResultsControllerDelegate

extension DeckDetailTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type:
        NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
        cards = controller.fetchedObjects as! [Card]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}


// MARK: - UISearchResultsUpdating

extension DeckDetailTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredCards = searchText.isEmpty ? cards : cards.filter {
                $0.frontText!.rangeOfString(searchText, options: [.CaseInsensitiveSearch, .AnchoredSearch]) != nil
            }
            self.searchText = searchText
            resultsController.tableView.editing = editing
            resultsController.tableView.reloadData()
        }
    }
}


// MARK: - DZNEmptyDataSetSource

extension DeckDetailTableViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = scrollView === tableView ? "Create a card list" : "No results found"
        let attributedString = NSAttributedString(string: string, font: .avenirHeavy(22))
        return attributedString
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let string = "No cards were found that match '\(searchText)'"
        let attributedString = NSAttributedString(string: string, font: .avenirBook(17))
        return scrollView === tableView ? nil : attributedString
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let named = scrollView === tableView ? "cards" : "search"
        let size = CGSizeMake(60.0, 60.0)
        let image = imageResize(UIImage(named: named)!, sizeChange: size)
        return UIDevice.currentDevice().orientation.isLandscape ?  nil : image
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let string = "+ Add Cards"
        let tintColor = UIColor(red: 39.0/255.0, green: 122.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let attributedString = NSAttributedString(string: string, font: .avenirBook(15), color: tintColor)
        return scrollView === tableView ? attributedString : nil
    }

    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return scrollView === tableView ? 0.0 : -40.0
    }
    
}


// MARK: - DZNEmptyDataSetDelegate

extension DeckDetailTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return scrollView === tableView ? false : true
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapButton button: UIButton!) {
        if scrollView === tableView {
            performSegueWithIdentifier("AddCard", sender: self)
        }
    }
}

