//
//  ShowViewController.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/26/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit
import Cartography
import ZLSwipeableViewSwift

class ShowViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rewindBarButtonItem: UIBarButtonItem!
    
    var swipeableView: ZLSwipeableView!
    
    var cards: [Card]!
    
    var defaultCardSize: CGSize!
    
    var flipped = false
    var isBack = false
    var tapped = false
    
    var cardIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flipped = isBack
        
        setupSwipeableView()
        updateRightBarButtonItem()
    }
    
    
    func findIndex(cards: [Card], _ valueToFind: String) -> Int? {
        for (index, card) in cards.enumerate() {
            if card.frontText == valueToFind {
                return index
            }
        }
        return nil
    }
    
    
    func swapTwoValues<T>(inout a: T, inout _ b: T) {
        let temporaryA = a
        a = b
        b = temporaryA
    }
    
    
    func swap() {
        let cardView = swipeableView.history.last as! CardView
        let i = findIndex(cards, cardView.frontText)!
        let min = cards.count / 3
        let max = cards.count - min
        let j = Int(arc4random_uniform(UInt32((max - min) + 1))) + min
        
        swapTwoValues(&cards[i], &cards[j])
    }
    
    func setupSwipeableView() {
        defaultCardSize = CGSize(width: 300, height: 200)
        
        swipeableView = ZLSwipeableView()
        swipeableView.numberOfHistoryItem = UInt.max
        swipeableView.allowedDirection = [.All]
        
        contentView.addSubview(swipeableView)
        
        swipeableView.didSwipe = { cardView, direction, vector in
            self.flipped = self.isBack
            if self.tapped {
                self.swap()
                self.tapped = false
            }
            self.updateRightBarButtonItem()
        }
        
        swipeableView.didTap = { cardView, location in
            self.tapped = true
            self.flipped = !self.flipped
            self.flip(cardView)
        }
        
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left
            view1.right == view2.right
            view1.top == view2.top
            view1.bottom == view2.bottom
        }
        
        swipeableView.numberOfActiveView = cards.count > 7 ? 7 : UInt(cards.count)
        swipeableView.animateView = { cardView, index, views, swipeableView in
            let degree = CGFloat(index)
            let duration = 0.5
            let scale = 1 - degree * 0.05
            let translation = CGPoint(x: 0, y: -degree * 10)
            let offset = CGPoint(x: 0, y: CGRectGetHeight(swipeableView.bounds) * 0.3)
            self.scaleAndTranslateView(cardView, scale: scale, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
    }
    
    
    func scaleAndTranslateView(view: UIView, scale: CGFloat, translation: CGPoint, duration: NSTimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
        UIView.animateWithDuration(duration, delay: 0, options: .AllowUserInteraction, animations: {
            view.center = swipeableView.convertPoint(swipeableView.center, fromView: swipeableView.superview)
            var transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
            transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y)
            transform = CGAffineTransformTranslate(transform, translation.x, translation.y)
            transform = CGAffineTransformScale(transform, scale, scale)
            view.transform = transform
            }, completion: nil)
    }
    
    
    func nextCardView() -> UIView? {
        if cardIndex >= cards.count {
            cardIndex = 0
        }
        let card = cards[cardIndex]
        let frame = CGRect(origin: CGPointZero, size: defaultCardSize)
        let cardView = CardView(frame: frame)
        cardView.frontText = card.frontText
        cardView.backText = card.backText
        cardView.isBack = isBack
        cardIndex += 1
        return cardView
    }
    
    
    func flip(view: UIView) {
        let cardView = view as! CardView
        UIView.transitionWithView(view, duration: 0.5, options: [.TransitionFlipFromTop, .AllowUserInteraction], animations: {
            cardView.label.text = self.flipped ? cardView.backText : cardView.frontText
            }, completion: { finished in
                cardView.label.setNeedsDisplay()
        })
    }
    
    
    // MARK: - Actions
    
    @IBAction func shuffle(sender: UIBarButtonItem) {
        let shuffledDeck = cards.shuffle()
        cards = shuffledDeck
        reloadViews()
    }
    
    @IBAction func swap(sender: UIBarButtonItem) {
        isBack = !isBack
        reloadViews()
    }
    
    
    @IBAction func reload(sender: UIBarButtonItem) {
        reloadViews()
    }
    
    @IBAction func rewind(sender: UIBarButtonItem) {
        swipeableView.rewind()
        updateRightBarButtonItem()
    }
    
    func reloadViews() {
        cardIndex = 0
        swipeableView.history.removeAll()
        swipeableView.discardViews()
        swipeableView.loadViews()
        updateRightBarButtonItem()
    }
    
    func updateRightBarButtonItem() {
        let historyLength = swipeableView.history.count
        let enabled = historyLength != 0
        navigationItem.rightBarButtonItem?.enabled = enabled
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
}