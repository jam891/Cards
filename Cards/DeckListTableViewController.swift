//
//  DeckListTableViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/23/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class DeckListTableViewController: UITableViewController {
    
    static let nibName = "DeckTableViewCell"
    static let cellIdentifier = "Deck"
    
    
    
    @IBOutlet weak var searchBarContainer: UIView!
    
    var fetchedResultsController: NSFetchedResultsController!
    var resultsController: UITableViewController!
    var searchController: UISearchController!
    
    var decks: [Deck]!
    var filteredDecks: [Deck]!
    var selectedDeck: Deck!
    var searchText: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        decks = []
        filteredDecks = []

        configureSearchController()
        initializeFetchedResultsController()
        
        navigationItem.rightBarButtonItem = editButtonItem()
        let nib = UINib(nibName: DeckListTableViewController.nibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: DeckListTableViewController.cellIdentifier)
    }
    
    
    
    // MARK: - Initialize fetched results controller
    
    func initializeFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: Deck.EntityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cardsModel.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            decks = fetchedResultsController.fetchedObjects as! [Deck]
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
    // MARK: - Initialize search controller
    
    func configureSearchController() {
        let nib = UINib(nibName: DeckListTableViewController.nibName, bundle: nil)
        resultsController = UITableViewController(style: .Grouped)
        resultsController.tableView.registerNib(nib, forCellReuseIdentifier: DeckListTableViewController.cellIdentifier)
        resultsController.tableView.rowHeight = 50.0
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
        resultsController.tableView.emptyDataSetSource = self
        resultsController.tableView.emptyDataSetDelegate = self
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchResultsUpdater = self
        
        searchBarContainer.addSubview(searchController.searchBar)
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        definesPresentationContext = true
    }
    
   
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableView ? decks.count : filteredDecks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DeckListTableViewController.cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
 
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let deck = searchController.active ? filteredDecks[indexPath.row] : decks[indexPath.row]
        if let cell = cell as? DeckTableViewCell {
            cell.textLabel!.text = deck.name
            cell.detailTextLabel?.text = "\(deck.cards!.count) cards"
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return decks.count == 1 ? .None : .Delete
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            decks.removeAtIndex(indexPath.row)
            let deck = fetchedResultsController.objectAtIndexPath(indexPath) as! Deck
            cardsModel.delete(deck.objectID)
        }
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movedDeck = decks[sourceIndexPath.row]
        decks.removeAtIndex(sourceIndexPath.row)
        decks.insert(movedDeck, atIndex: destinationIndexPath.row)
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return decks.count > 1 ? true : false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedDeck = tableView === self.tableView ? decks[indexPath.row] : filteredDecks[indexPath.row]
        performSegueWithIdentifier("DeckDetail", sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView === resultsController.tableView && filteredDecks?.count != 0 ? "deck" : nil
    }
  
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        selectedDeck = decks[indexPath.row]
        performSegueWithIdentifier("EditDeck", sender: self)
    }

   
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "DeckDetail":
                let detailViewController = segue.destinationViewController as! DeckDetailTableViewController
                detailViewController.title = selectedDeck.name
                detailViewController.deck = selectedDeck
            case "AddDeck":
                if let navigationController = segue.destinationViewController as? UINavigationController,
                    let deckAddViewController = navigationController.viewControllers.first as? DeckAddTableViewController {
                    deckAddViewController.didFinish = { name in
                        self.selectedDeck = cardsModel.createDeck(name)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        self.performSegueWithIdentifier("DeckDetail", sender: self)
                    }
                }
            case "EditDeck":
                let deckEditViewController = segue.destinationViewController as! DeckEditTableViewController
                deckEditViewController.title = selectedDeck.name
                deckEditViewController.deck = selectedDeck
                deckEditViewController.didFinish = { deck in
                    cardsModel.update(deck)
                }
                deckEditViewController.didDelete = { deck in
                    cardsModel.delete(deck.objectID)
                }
                deckEditViewController.didFailure = { title, message in
                    self.showAlert(title, message: message)
                }
            default:
                break
            }
        }
    }
    
    @IBAction func unwindToDeckList(sender: UIStoryboardSegue) {
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
        resultsController.tableView.reloadEmptyDataSet()
    }
}



// MARK: - NSFetchedResultsControllerDelegate

extension DeckListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
        decks = controller.fetchedObjects as! [Deck]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}


// MARK: - UISearchResultsUpdating

extension DeckListTableViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredDecks = searchText.isEmpty ? decks : decks.filter {
                $0.name!.rangeOfString(searchText, options: [.CaseInsensitiveSearch, .AnchoredSearch]) != nil
            }
            self.searchText = searchText
            resultsController.tableView.editing = editing
            resultsController.tableView.reloadData()
        }
    }
}


// MARK: - DZNEmptyDataSetSource

extension DeckListTableViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No results found", font: .avenirHeavy(22))
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No decks were found that match '\(searchText)'", font: .avenirBook(17))
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let size = CGSizeMake(60, 60)
        let image = imageResize(UIImage(named: "search")!, sizeChange: size)
        return UIDevice.currentDevice().orientation.isLandscape ?  nil : image
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
    
}

// MARK: - DZNEmptyDataSetDelegate

extension DeckListTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

