//
//  GenreTableViewCell.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/13/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {
    @IBOutlet weak var genreImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        genreImageView.contentMode = UIViewContentMode.ScaleAspectFit
        genreImageView.clipsToBounds = true
        genreImageView.tintColor = UIColor.lightGrayColor()
        
        let backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = UIColor.blackColor()
        selectedBackgroundView = backgroundView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
