//
//  Card+CoreDataProperties.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Card {

    @NSManaged var backText: String?
    @NSManaged var frontText: String?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var transcription: String?
    @NSManaged var partOfSpeech: String?
    @NSManaged var examples: String?
    @NSManaged var deck: Deck?

}
