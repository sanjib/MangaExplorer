//
//  SettingsFetchFrequencyTableViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/21/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class SettingsFetchFrequencyTableViewController: UITableViewController {
    @IBOutlet weak var latestDailyTableViewCell: UITableViewCell!
    @IBOutlet weak var latestWeeklyTableViewCell: UITableViewCell!
    @IBOutlet weak var latestMonthlyTableViewCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        switch UserDefaults.sharedInstance.latestMangasFetchFrequency {
        case UserDefaults.LatestMangasFetchFrequency.Daily:
            latestDailyTableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            latestWeeklyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
            latestMonthlyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
        case UserDefaults.LatestMangasFetchFrequency.Weekly:
            latestDailyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
            latestWeeklyTableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            latestMonthlyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
        case UserDefaults.LatestMangasFetchFrequency.Monthly:
            latestDailyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
            latestWeeklyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
            latestMonthlyTableViewCell.accessoryType = UITableViewCellAccessoryType.Checkmark
        default:
            break
        }
    }

    // MARK: - Table view delegates

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel.textColor = UIColor.whiteColor()
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
            case latestDailyTableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    latestWeeklyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    latestMonthlyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.latestMangasFetchFrequency = UserDefaults.LatestMangasFetchFrequency.Daily
            case latestWeeklyTableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    latestDailyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    latestMonthlyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.latestMangasFetchFrequency = UserDefaults.LatestMangasFetchFrequency.Weekly
            case latestMonthlyTableViewCell:
                if cell.accessoryType == UITableViewCellAccessoryType.None {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    latestDailyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                    latestWeeklyTableViewCell.accessoryType = UITableViewCellAccessoryType.None
                }
                UserDefaults.sharedInstance.latestMangasFetchFrequency = UserDefaults.LatestMangasFetchFrequency.Monthly
            default:
                break
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
