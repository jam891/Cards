//
//  UITableViewCell.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            return table as? UITableView
        }
    }
    
    
    /**
     Jump to the previous cell, located above the current cell.
     
     Usage: when the user types SHIFT TAB on the keyboard, then we want to jump to a cell above.
     */
    func makePreviousCellFirstResponder() {
        tableView!.makePreviousCellFirstResponder(self)
    }
    
    /**
     Jump to the next cell, located below the current cell.
     
     Usage: when the user hits TAB on the keyboard, then we want to jump to a cell below.
     */
    func makeNextCellFirstResponder() {
        tableView!.makeNextCellFirstResponder(self)
    }
    
    /**
     Determines if it's possible to jump to the cell above.
     */
    func canMakePreviousCellFirstResponder() -> Bool {
        return tableView!.canMakePreviousCellFirstResponder(self) ?? false
    }
    
    /**
     Determines if it's possible to jump to the cell below.
     */
    func canMakeNextCellFirstResponder() -> Bool {
        return tableView!.canMakeNextCellFirstResponder(self) ?? false
    }
    
    
}
