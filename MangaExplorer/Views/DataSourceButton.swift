//
//  DataSourceButton.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class DataSourceButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let whiteColor: CGFloat = 255
        tintColor = UIColor(red: whiteColor, green: whiteColor, blue: whiteColor, alpha: 0.6)
        
        let blackColor: CGFloat = 0
        layer.backgroundColor = UIColor(red: blackColor, green: blackColor, blue: blackColor, alpha: 0.5).CGColor

        layer.cornerRadius = 5.0
        contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    }

}
