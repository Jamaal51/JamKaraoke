//
//  Song.swift
//  JamKaraoke
//
//  Created by Jamaal Sedayao on 5/12/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import Foundation


class Song {
    
    // Array of dictionary with 3 key, value pairings
    
    var songsArray = [Dictionary<String, AnyObject>]()
    
    let songDict: Dictionary<String, NSURL> = [
        "Don't Stop Believin' - Journey" : NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dontstopbelievinjourney", ofType: "mp3")!),
        "Uptown Funk by Mark Ronson/Bruno Mars" : NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("uptownfunk", ofType: "mp3")!)
        ]
    
    func initializeData() -> [Dictionary<String, AnyObject>]{
        
        let journeyLyrics: [String:String] = [
            "00:17":"Just a small town girl living in a lonely world",
            "00:24": "She took the midnight train going anywhere"
        ]
        
        
        let brunoLyrics: [String:String] = [
            "00:20":"This hit, that ice cold",
            "00:10":"Michele Pfifer, that white gold"
        ]
        
        let dontStopBelievin : [String:AnyObject] = [
            "songName" : String("Don't Stop Believin"),
            "songFile" : returnURLPath("dontstopbelievinjourney"),
            "songLyrics" :  journeyLyrics
        ]
        
        let uptownFunk : [String: AnyObject] = [
            "songName" : String("Uptown Funk"),
            "songFile" : returnURLPath("uptownfunk"),
            "songLyrics" : brunoLyrics
        ]
    
        songsArray.append(dontStopBelievin)
        songsArray.append(uptownFunk)
        
        return songsArray
    }
    
    func returnURLPath(songString:String) -> NSURL {
        return NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(songString, ofType: "mp3")!)
    }
    
    
}