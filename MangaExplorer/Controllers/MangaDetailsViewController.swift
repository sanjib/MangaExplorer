//
//  MangaDetailsViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class MangaDetailsViewController: UIViewController {
    
    var manga: Manga!

    override func viewDidLoad() {
        super.viewDidLoad()

        println(manga.title)
        
    }
}
