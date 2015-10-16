//
//  SettingsDisplayMaxTableViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/23/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class SettingsDisplayMaxTableViewController: UITableViewController {
    @IBOutlet weak var topRated300TableViewCell: UITableViewCell!
    @IBOutlet weak var topRated600TableViewCell: UITableViewCell!
    @IBOutlet weak var topRated1200TableViewCell: UITableViewCell!
    @IBOutlet weak var topRated2400TableViewCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switch UserDefaults.sharedInstance.topRatedMangasDisplayMax {
        case UserDefaults.TopRatedMangasDisplayMax.Top300:
            topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
        case UserDefaults.TopRatedMangasDisplayMax.Top600:
            topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
        case UserDefaults.TopRatedMangasDisplayMax.Top1200:
            topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
        case UserDefaults.TopRatedMangasDisplayMax.Top2400:
            topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
            topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
        default:
            break
        }
    }

    // MARK: - Table view delegates
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel!.textColor = UIColor.whiteColor()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = backgroundView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            switch cell {
            case topRated300TableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.topRatedMangasDisplayMax = UserDefaults.TopRatedMangasDisplayMax.Top300
            case topRated600TableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.topRatedMangasDisplayMax = UserDefaults.TopRatedMangasDisplayMax.Top600
            case topRated1200TableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated2400TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.topRatedMangasDisplayMax = UserDefaults.TopRatedMangasDisplayMax.Top1200
            case topRated2400TableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    topRated300TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated600TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    topRated1200TableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.topRatedMangasDisplayMax = UserDefaults.TopRatedMangasDisplayMax.Top2400
            default:
                break
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("performFetchForFetchedResultsControllerInTopRatedMangas", object: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
