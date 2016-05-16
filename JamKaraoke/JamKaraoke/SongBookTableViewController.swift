//
//  SongBookTableViewController.swift
//  JamKaraoke
//
//  Created by Jamaal Sedayao on 5/12/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import UIKit

class SongBookTableViewController: UITableViewController {
    
    let song = Song()
    //let songs = Song().songDict
    var songList = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Songs!"
        songList = song.initializeData()
        
        //songList = song.songsArray
        
}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songListID", forIndexPath: indexPath)

        var thisSong = songList[indexPath.row]
        let songName = thisSong.removeValueForKey("songName")!
        
        cell.textLabel!.text = String(songName)

        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "segueToKaraokeVC"){
            let vc = segue.destinationViewController as! KaraokeViewController
            
            if let indexPath = tableView.indexPathForSelectedRow{
                
                let thisSong = songList[indexPath.row]
                vc.selectedSong = thisSong
            }
            
        }
    }
    
}
