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

public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    func groupBy<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key]?.append(el) ?? {dict[key] = [el]}()
        }
        return dict
    }
}

class SessionListViewController : UITableViewController {
    var _dayId:Int = 0
    var _sessions = [(NSDate, [Session])]() // array of tuples of startDate/sessionArray,
    
    func setLabel(label:String, imageName:String, dayId:Int) {
        let image = UIImage(named: imageName)
        self.tabBarItem = UITabBarItem(title: label, image: image, selectedImage: image)
        
        _dayId = dayId
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        _sessions = [(NSDate, [Session])]()
        self.tableView.reloadData()
        sender.endRefreshing()
        
        loadDataAndClearCache(true)
    }
    
    override func viewDidLoad() { // go and load the data from the API
        loadDataAndClearCache(false)
    }
    
    func loadDataAndClearCache(clearCache:Bool) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.tabBarController!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        spinner.startAnimating()
        
        var callback = { (x:GetSessionsResponse) in }
        let dayId = _dayId
        callback = { [weak self] (response:GetSessionsResponse) -> () in
            guard let sself = self else { return }
            
            // the ignite api is RIDICULOUS. 
            // When you ask for page 1, it returns items [0-10]
            // When you ask for page 2, it returns items [0-20]... Yes that's right, NOT articles 11-20 as you'd expect
            sself._sessions.removeAll()
            
            let grouped = response.sessions.groupBy{ $0.schedule.startDateTime }
            let sorted = grouped.sort{ $0.0.compare($1.0) != .OrderedDescending }
            
            for (dt, items) in sorted {
                // stick it on the end; server gives us things in date order so we can be lazy and not sort
                // else we'd have to sort the tuples by ascending dt (so probably parse to NSDate)
                
                var sectionIndex = sself._sessions.indexOf{ $0.0.compare(dt) == .OrderedSame }
                if sectionIndex == nil {
                    sectionIndex = sself._sessions.count
                    sself._sessions.append((dt, [Session]()))
                }
                
                for item in items {
                    var coll = sself._sessions[sectionIndex!].1
                    coll.append(item)
                    sself._sessions[sectionIndex!].1 = coll // swift arrays have copy semantics
                }
            }
            
            sself.tableView.reloadData()
            
            // either stop the spinner or get the next request
            if response.pageNumber < response.pagesCount {
                // because of the RIDICULOUS paging, we can simply request the last page once we know how many in total there are
                AppDelegate.api.cachedGetSessions(dayId, pageNumber:response.pagesCount, clearCache:clearCache, callback:callback)
            } else { // all done
                spinner.stopAnimating()
                sself.tabBarController!.navigationItem.leftBarButtonItem = nil
            }
        }
        
        // Api numbers pages with 1-based indexing
        AppDelegate.api.cachedGetSessions(_dayId, pageNumber:1, clearCache:clearCache, callback:callback)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _sessions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sessions[section].1.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _sessions[section].1.first?.schedule.formattedStartDate
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("sessionCell") as? SessionTableViewCell else {
            fatalError("can't dequeue cell!")
        }
        let session = _sessions[indexPath.section].1[indexPath.row]
        
        cell.setTitle(session.name, speaker: session.speakers.first?.name ?? "", room: session.schedule.formattedVenueString)
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let bg = view as? UITableViewHeaderFooterView {
            bg.backgroundView?.backgroundColor = UIColor(red: 0.18, green: 0.745, blue: 0.933, alpha: 1)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "sessionDetails") {
            let vc = segue.destinationViewController as! SessionDetailsViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                vc.session = _sessions[indexPath.section].1[indexPath.row]
            }
        }
    }
}

class SessionTableViewCell : UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var speakerLabel: UILabel!
    @IBOutlet private weak var roomLabel: UILabel!
    
    func setTitle(title:String, speaker:String, room:String) {
        titleLabel.text = title
        speakerLabel.text = speaker
        roomLabel.text = room
    }
    
}

