//
//  TopRatedMangaCollectionViewCell.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class TopRatedMangaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mangaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.hidesWhenStopped = true
        
        mangaImageView.contentMode = UIViewContentMode.ScaleAspectFill
        mangaImageView.clipsToBounds = true
        
        ratingsLabel.layer.borderColor = UIColor.yellowColor().CGColor
        ratingsLabel.layer.borderWidth = 0.25
        
        titleLabel.textColor = UIColor.whiteColor()
        authorLabel.textColor = UIColor.whiteColor()
    }
}
