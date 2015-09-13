//
//  GenresViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/5/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit
import CoreData

class GenresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private var allGenres = [String]()
    private var selectedGenre: String?

    private let genreImages = [
        "action": UIImage(named: "action"),
        "adventure": UIImage(named: "adventure"),
        "comedy": UIImage(named: "comedy"),
        "drama": UIImage(named: "drama"),
        "fantasy": UIImage(named: "fantasy"),
        "horror": UIImage(named: "horror"),
        "magic": UIImage(named: "magic"),
        "mystery": UIImage(named: "mystery"),
        "psychological": UIImage(named: "psychological"),
        "romance": UIImage(named: "romance"),
        "science fiction": UIImage(named: "science fiction"),
        "slice of life": UIImage(named: "slice of life"),
        "supernatural": UIImage(named: "supernatural"),
        "thriller": UIImage(named: "thriller"),
        "tournament": UIImage(named: "tournament"),
        "unknown": UIImage(named: "genres")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // CoreData
        allGenres = fetchAllGenres()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("didReceiveMemoryWarning: GenresViewController")
    }
    
    // MARK: - CoreData
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    func fetchAllGenres() -> [String] {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Genre", inManagedObjectContext: sharedContext)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = ["name"]
        
        var error: NSError? = nil
        var results = sharedContext.executeFetchRequest(fetchRequest, error: &error)
        if let error = error {
            return [String]()
        }

        var genres = [String]()
        for genre in results as! [NSDictionary] {
            if let genreName = genre["name"] as? String {
                genres.append(genreName)
            }
        }
        return genres
    }
    
    // MARK: - TableView delegates & data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allGenres.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GenreCell", forIndexPath: indexPath) as! GenreTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedGenre = allGenres[indexPath.row]
        performSegueWithIdentifier("GenreCollectionSegue", sender: self)
    }
    
    // MARK: - Configure cell
    
    func configureCell(cell: GenreTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let genreName = allGenres[indexPath.row]
        
        if let genreImage = genreImages[genreName] {
            cell.genreImageView.image = genreImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        } else {
            if let genreImage = genreImages["unknown"] {
                cell.genreImageView.image = genreImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            }
        }
        
        cell.genreLabel.text = genreName.capitalizedString
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GenreCollectionSegue" {
            let vc = segue.destinationViewController as! TopRatedMangasViewController
            vc.genre = selectedGenre
        }
    }
}
