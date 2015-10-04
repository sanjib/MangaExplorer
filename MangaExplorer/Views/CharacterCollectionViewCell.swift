//
//  CharacterCollectionViewCell.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/4/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var characterImageView: UIImageView!
//    @IBOutlet weak var characterNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        characterImageView.contentMode = UIViewContentMode.ScaleAspectFill
        characterImageView.clipsToBounds = true
        
    }
    
}
