//
//  MangaListSegmentedControl.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 10/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class MangaListSegmentedControl: UISegmentedControl {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.whiteColor()
        
        setBackgroundImage(UIImage(named: "segmentedControlBackgroundNormal"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        setBackgroundImage(UIImage(named: "segmentedControlBackgroundSelected"), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
    }
    
}
