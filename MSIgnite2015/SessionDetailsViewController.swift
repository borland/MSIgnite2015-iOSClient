//
//  SecondViewController.swift
//  MSIgnite2015
//
//  Created by Orion Edwards on 2/09/15.
//  Copyright © 2015 Orion Edwards. All rights reserved.
//

import UIKit

class SessionDetailsViewController: UITableViewController {
    
    var session = Session()
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? SessionDetailsCell else {
            fatalError("can't find cell in storyboard")
        }
        
        cell.label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        switch(indexPath.row) {
        case 0:
            cell.label.text = session.name
            cell.label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        case 1:
            cell.label.text = session.details.level
        case 2:
            cell.label.text = session.schedule.formattedStartDate
        case 3:
            cell.label.text = session.schedule.formattedVenueString
        case 4:
            cell.label.text = session.description
            cell.label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        case 5:
            cell.label.text = session.speakers.first?.name
        case 6:
            cell.label.text = session.speakers.first?.bio
            cell.label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        default:
            cell.label.text = nil
        }
        
        return cell
    }
}

class SessionDetailsCell : UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
}

