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
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
        
        characterImageView.contentMode = UIViewContentMode.ScaleAspectFill
        characterImageView.clipsToBounds = true        
    }
    
}
