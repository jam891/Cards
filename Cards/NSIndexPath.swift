//
//  NSIndexPath.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation


extension NSIndexPath {
    
    /**
     Indexpath of the previous cell.
     
     This function is complex because it deals with empty sections and invalid indexpaths.
     */
    func indexPathForPreviousCell(tableView: UITableView) -> NSIndexPath? {
        if section < 0 || row < 0 {
            return nil
        }
        let sectionCount = tableView.numberOfSections
        if section < 0 || section >= sectionCount {
            return nil
        }
        let firstRowCount = tableView.numberOfRowsInSection(section)
        if row > 0 && row <= firstRowCount {
            return NSIndexPath(forRow: row - 1, inSection: section)
        }
        var currentSection = section
        while true {
            currentSection -= 1
            if currentSection < 0 || currentSection >= sectionCount {
                return nil
            }
            let rowCount = tableView.numberOfRowsInSection(currentSection)
            if rowCount > 0 {
                return NSIndexPath(forRow: rowCount - 1, inSection: currentSection)
            }
        }
    }
    
    /**
     Indexpath of the next cell.
     
     This function is complex because it deals with empty sections and invalid indexpaths.
     */
    func indexPathForNextCell(tableView: UITableView) -> NSIndexPath? {
        if section < 0 {
            return nil
        }
        let sectionCount = tableView.numberOfSections
        var currentRow = row + 1
        var currentSection = section
        while true {
            if currentSection >= sectionCount {
                return nil
            }
            let rowCount = tableView.numberOfRowsInSection(currentSection)
            if currentRow >= 0 && currentRow < rowCount {
                return NSIndexPath(forRow: currentRow, inSection: currentSection)
            }
            if currentRow > rowCount {
                return nil
            }
            currentSection += 1
            currentRow = 0
        }
    }
    
}
