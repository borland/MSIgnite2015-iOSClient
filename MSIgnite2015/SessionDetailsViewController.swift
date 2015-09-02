// Copyright (c) 2015 Orion Edwards
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import SafariServices

class SessionDetailsViewController: UITableViewController, SFSafariViewControllerDelegate {
    
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
        var titleCell:SessionTitleCell!
        var cell:SessionDetailsCell!
        if(indexPath.row == 0) {
            titleCell = tableView.dequeueReusableCellWithIdentifier("titleCell") as? SessionTitleCell
            if(titleCell == nil) {
                fatalError("can't find titleCell in storyboard")
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("cell") as? SessionDetailsCell
            if(cell == nil) {
                fatalError("can't find cell in storyboard")
            }
            cell.label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        
        switch(indexPath.row) {
        case 0:
            titleCell.label.text = session.name
            return titleCell
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0) {
            if let url = NSURL(string: "https://msignite.nz/sessions/session-details/\(session.sessionId)") {
                let vc = SFSafariViewController(URL:url)
                vc.delegate = self
                navigationController!.presentViewController(vc, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}

class SessionTitleCell : UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
}

class SessionDetailsCell : UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
}

