//
//  MangaDetailsViewController.swift
//  MangaExplorer
//
//  Created by Sanjib Ahmad on 9/9/15.
//  Copyright (c) 2015 Object Coder. All rights reserved.
//

import UIKit

class MangaDetailsViewController: UIViewController {
    @IBOutlet weak var mangaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alternativeTitleLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    @IBOutlet weak var bayesianAverageLabel: UILabel!
    @IBOutlet weak var plotSummaryLabel: UILabel!
    
    @IBOutlet weak var addToWishListButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    
    var manga: Manga!
    
    private let photoPlaceholderImage = UIImage(named: "mangaPlaceholder")
    
    private var attributesForHeading: [String:AnyObject] {
        let fontAttribute = UIFont(name: "Helvetica Neue", size: 16.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let attributes = [
            NSFontAttributeName: fontAttribute,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }
    
    private var attributesForStaffHeading: [String:AnyObject] {
        let fontAttribute = UIFont(name: "Helvetica Neue", size: 14.0)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        
        let attributes = [
            NSFontAttributeName: fontAttribute,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        return attributes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bayesianAverageLabel.layer.cornerRadius = 3.0
        bayesianAverageLabel.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("manga id: \(manga.id)")
        
        setMangaImage()
        setTitle()
        setStaff()
        setBayesianAverage()
        setPlotSummary()
        setAlternativeTitle()
    }
    
    // MARK: - set content
    
    private func setMangaImage() {
        if let imageData = manga.imageData {
            mangaImageView.image = UIImage(data: imageData)
        } else {
            mangaImageView.image = photoPlaceholderImage
        }
    }
    
    private func setTitle() {
        let titleAttributedString = NSMutableAttributedString(string: manga.title)
        titleAttributedString.addAttribute(NSKernAttributeName, value: -1.0, range: NSRange(location: 0, length: titleAttributedString.length))
        titleLabel.attributedText = titleAttributedString
    }
    
    private func setStaff() {
        var allStaffDidAddFirstLine = false
        var allStaffAttributedString = NSMutableAttributedString(string: "")

        var personsConcatenatedByTask = [String:String]()
        
        for staff in manga.staff {
            if personsConcatenatedByTask[staff.task] != nil {
                personsConcatenatedByTask[staff.task]! += ", " + staff.person as String
            } else {
                personsConcatenatedByTask[staff.task] = staff.person
            }
        }
        
        for (task, person) in personsConcatenatedByTask {
            var staffAttributedString = NSMutableAttributedString(string: "")
            if !allStaffDidAddFirstLine {
                allStaffDidAddFirstLine = true
                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: task))
            } else {
                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + task))
            }
            staffAttributedString.addAttributes(attributesForStaffHeading, range: NSRange(location: 0, length: staffAttributedString.length))
            staffAttributedString.appendAttributedString(NSAttributedString(string: " " + person))
            
            allStaffAttributedString.appendAttributedString(staffAttributedString)
        }
        
//        for staff in manga.staff {
//            var staffAttributedString = NSMutableAttributedString(string: "")
//            if !allStaffDidAddFirstLine {
//                allStaffDidAddFirstLine = true
//                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: staff.task))
//            } else {
//                staffAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + staff.task))
//            }
//            staffAttributedString.addAttributes(attributesForStaffHeading, range: NSRange(location: 0, length: staffAttributedString.length))
//            staffAttributedString.appendAttributedString(NSAttributedString(string: " " + staff.person))
//            
//            allStaffAttributedString.appendAttributedString(staffAttributedString)
//        }
        staffLabel.attributedText = allStaffAttributedString
    }
    
    private func setBayesianAverage() {
        if manga.bayesianAverage > 0 {
            let average = Double(round(manga.bayesianAverage*10)/10)
            bayesianAverageLabel.text = "\(average)"
        } else {
            bayesianAverageLabel.text = ""
        }
    }
    
    private func setPlotSummary() {
        if let plotSummary = manga.plotSummary {
            var plotSummaryAttributedString = NSMutableAttributedString(string: "Plot Summary")
            plotSummaryAttributedString.addAttributes(attributesForHeading, range: NSRange(location: 0, length: plotSummaryAttributedString.length))
            plotSummaryAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + plotSummary))
            plotSummaryLabel.attributedText = plotSummaryAttributedString
            
        } else {
            plotSummaryLabel.attributedText = NSAttributedString(string: "")
        }
    }
    
    private func setAlternativeTitle() {
        var allAlternativeTitles = ""
        for alternativeTitle in manga.alternativeTitle {
            if allAlternativeTitles.isEmpty {
                allAlternativeTitles = alternativeTitle.title
            } else {
                allAlternativeTitles += ", " + alternativeTitle.title
            }
        }
        if !allAlternativeTitles.isEmpty {
            var allAlternativeTitlesAttributedString = NSMutableAttributedString(string: "Alternative Titles")
            allAlternativeTitlesAttributedString.addAttributes(attributesForHeading, range: NSRange(location: 0, length: allAlternativeTitlesAttributedString.length))
            allAlternativeTitlesAttributedString.appendAttributedString(NSMutableAttributedString(string: "\n" + allAlternativeTitles))
            alternativeTitleLabel.attributedText = allAlternativeTitlesAttributedString
        } else {
            alternativeTitleLabel.attributedText = NSAttributedString(string: "")
        }
    }
    
}
