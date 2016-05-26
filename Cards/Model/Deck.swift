//
//  Deck.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/23/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation
import CoreData


class Deck: NSManagedObject {

    static let EntityName = "Deck"
    
    
    func createCard(frontText: String, backText: String, transcription: String, partOfSpeech: String, examples: String) -> Card {
        let card = NSEntityDescription.insertNewObjectForEntityForName(Card.EntityName, inManagedObjectContext: managedObjectContext!) as! Card
        card.deck = self
        card.frontText = frontText
        card.backText = backText
        card.transcription = transcription
        card.partOfSpeech = partOfSpeech
        card.examples = examples
        card.timeStamp = NSDate()
        return card
    }
    
    func getById(id: NSManagedObjectID) -> Card? {
        return managedObjectContext!.objectWithID(id) as? Card
    }
    
    func update(updatedCard: Card) {
        if let card = getById(updatedCard.objectID) {
            card.frontText = updatedCard.frontText
            card.backText = updatedCard.backText
            card.transcription = updatedCard.transcription
            card.partOfSpeech = updatedCard.partOfSpeech
            card.examples = updatedCard.examples
        }
    }
    
    func deleteCard(id: NSManagedObjectID) {
        if let cardToDelete = getById(id) {
            managedObjectContext!.deleteObject(cardToDelete)
        }
    }
    
    func get(withPredicate predicate: NSPredicate) -> [Card] {
        let fetchRequest = NSFetchRequest(entityName: Card.EntityName)
        fetchRequest.predicate = predicate
        let cards = try! managedObjectContext!.executeFetchRequest(fetchRequest)
        return cards as! [Card]
    }


}
