//
//  UITableView.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation


extension UITableView {
    
    /**
     Determine where a cell is located in this tableview. Considers cells inside and cells outside the visible area.
     
     Unlike UITableView.indexPathForCell() which only looksup inside the visible area.
     UITableView doesn't let you lookup cells outside the visible area.
     UITableView.indexPathForCell() returns nil when the cell is outside the visible area.
     */
    func form_indexPathForCell(cell: UITableViewCell) -> NSIndexPath? {
        guard let dataSource = self.dataSource else { return nil }
        let sectionCount: Int = dataSource.numberOfSectionsInTableView?(self) ?? 0
        for section: Int in 0 ..< sectionCount {
            let rowCount: Int = dataSource.tableView(self, numberOfRowsInSection: section)
            for row: Int in 0 ..< rowCount {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                let dataSourceCell = dataSource.tableView(self, cellForRowAtIndexPath: indexPath)
                if dataSourceCell === cell {
                    return indexPath
                }
            }
        }
        return nil
    }
    
    /**
     Find a cell above that can be jumped to. Skip cells that cannot be jumped to.
     
     Usage: when the user types SHIFT TAB on the keyboard, then we want to jump to a cell above.
     */
    func indexPathForPreviousResponder(initialIndexPath: NSIndexPath) -> NSIndexPath? {
        guard let dataSource = self.dataSource else { return nil }
        var indexPath: NSIndexPath! = initialIndexPath
        while true {
            indexPath = indexPath.indexPathForPreviousCell(self)
            if indexPath == nil {
                return nil
            }
            
            let cell = dataSource.tableView(self, cellForRowAtIndexPath: indexPath)
            if cell.canBecomeFirstResponder() {
                return indexPath
            }
        }
    }
    
    /**
     Find a cell below that can be jumped to. Skip cells that cannot be jumped to.
     
     Usage: when the user hits TAB on the keyboard, then we want to jump to a cell below.
     */
    func indexPathForNextResponder(initialIndexPath: NSIndexPath) -> NSIndexPath? {
        guard let dataSource = self.dataSource else { return nil }
        var indexPath: NSIndexPath! = initialIndexPath
        while true {
            indexPath = indexPath.indexPathForNextCell(self)
            if indexPath == nil {
                return nil
            }
            
            let cell = dataSource.tableView(self, cellForRowAtIndexPath: indexPath)
            if cell.canBecomeFirstResponder() {
                return indexPath
            }
        }
    }
    
    /**
     Jump to a cell above.
     
     Usage: when the user types SHIFT TAB on the keyboard, then we want to jump to a cell above.
     */
    func makePreviousCellFirstResponder(cell: UITableViewCell) {
        guard let indexPath0 = form_indexPathForCell(cell) else { return }
        guard let indexPath1 = indexPathForPreviousResponder(indexPath0) else { return }
        guard let dataSource = self.dataSource else { return }
        scrollToRowAtIndexPath(indexPath1, atScrollPosition: .Middle, animated: true)
        let cell = dataSource.tableView(self, cellForRowAtIndexPath: indexPath1)
        cell.becomeFirstResponder()
    }
    
    /**
     Jump to a cell below.
     
     Usage: when the user hits TAB on the keyboard, then we want to jump to a cell below.
     */
    func makeNextCellFirstResponder(cell: UITableViewCell) {
        guard let indexPath0 = form_indexPathForCell(cell) else { return }
        guard let indexPath1 = indexPathForNextResponder(indexPath0) else { return }
        guard let dataSource = self.dataSource else { return }
        scrollToRowAtIndexPath(indexPath1, atScrollPosition: .Middle, animated: true)
        let cell = dataSource.tableView(self, cellForRowAtIndexPath: indexPath1)
        cell.becomeFirstResponder()
    }
    
    /**
     Determines if it's possible to jump to a cell above.
     */
    func canMakePreviousCellFirstResponder(cell: UITableViewCell) -> Bool {
        guard let indexPath0 = form_indexPathForCell(cell) else { return false }
        if indexPathForPreviousResponder(indexPath0) == nil { return false }
        if self.dataSource == nil { return false }
        return true
    }
    
    /**
     Determines if it's possible to jump to a cell below.
     */
    func canMakeNextCellFirstResponder(cell: UITableViewCell) -> Bool {
        guard let indexPath0 = form_indexPathForCell(cell) else { return false }
        if indexPathForNextResponder(indexPath0) == nil { return false }
        if self.dataSource == nil { return false }
        return true
    }
}
