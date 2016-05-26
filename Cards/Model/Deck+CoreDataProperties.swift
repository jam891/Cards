//
//  Deck+CoreDataProperties.swift
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

extension Deck {

    @NSManaged var name: String?
    @NSManaged var cards: NSSet?

}
