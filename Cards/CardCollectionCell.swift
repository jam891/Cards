//
//  CardCollectionCell.swift
//  Cards
//
//  Created by Vitaliy Delidov on 5/25/16.
//  Copyright © 2016 Vitaliy Delidov. All rights reserved.
//

import UIKit

class CardCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var frontText: UILabel!
    @IBOutlet weak var backText: UILabel!
    @IBOutlet weak var transcription: UILabel!
    @IBOutlet weak var partOfSpeech: UILabel!
    @IBOutlet weak var examples: UILabel!
    @IBOutlet weak var number: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
