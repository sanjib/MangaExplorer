//
//  AddToButton.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/12/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class AddToButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.whiteColor()
        
        layer.borderColor = titleLabel?.textColor.CGColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
