//
//  CardsModel.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/23/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation
import CoreData

class CardsModel {
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func createDeck(name: String) -> Deck {
        let deck = NSEntityDescription.insertNewObjectForEntityForName(Deck.EntityName, inManagedObjectContext: managedObjectContext) as! Deck
        deck.name = name
        return deck
    }
    
    func getAll() -> [Deck] {
        return get(withPredicate: NSPredicate(value: true))
    }
    
    func getById(id: NSManagedObjectID) -> Deck? {
        return managedObjectContext.objectWithID(id) as? Deck
    }
    
    func get(withPredicate predicate: NSPredicate) -> [Deck] {
        let fetchRequest = NSFetchRequest(entityName: Deck.EntityName)
        fetchRequest.predicate = predicate
        let decks = try! managedObjectContext.executeFetchRequest(fetchRequest)
        return decks as! [Deck]
    }
    
    func update(updatedDeck: Deck) {
        if let deck = getById(updatedDeck.objectID) {
            deck.name = updatedDeck.name
        }
    }
    
    func delete(id: NSManagedObjectID) {
        if let deckToDelete = getById(id) {
            managedObjectContext.deleteObject(deckToDelete)
        }
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

private let coreData = try! CoreData(sqliteDocumentName: "Cards.db", schemaName: "Cards")
let cardsModel = CardsModel(managedObjectContext: coreData.createManagedObjectContext())