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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
