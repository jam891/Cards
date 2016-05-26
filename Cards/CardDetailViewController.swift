//
//  CardDetailViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/24/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit
import HWSwiftyViewPager

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var pager: HWSwiftyViewPager!
    
    var deck: Deck!
    var card: Card!
    var cards: [Card]!
    
    var selectedCardIndex: Int!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for index in 0..<cards.count {
            if card == cards[index] {
                selectedCardIndex = index
            }
        }
        
        UIView.animateWithDuration(0, animations: {
            self.pager.reloadData()
        }) { finished in
            let indexPath = NSIndexPath(forItem: self.selectedCardIndex, inSection: 0)
            self.pager.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            self.pager.setPage(pageNum: self.selectedCardIndex, isAnimation: true)
        }
    }


}


extension CardDetailViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCollectionCell", forIndexPath: indexPath)
        if let cell = cell as? CardCollectionCell {
            configureCell(cell, atIndexPath: indexPath)
        }
        return cell
    }
    
    func configureCell(cell: CardCollectionCell, atIndexPath indexPath: NSIndexPath) {
        let card = cards[indexPath.row]
        
        cell.frontText.text = card.frontText
        cell.transcription.text = card.transcription?.characters.count > 0 ? "[\(card.transcription!)]" : card.transcription
        cell.partOfSpeech.text = card.partOfSpeech
        cell.backText.text = card.backText
        cell.examples.text = card.examples
        cell.number.text = "\(indexPath.row + 1) from \(cards.count)"
    }
    
    
}
