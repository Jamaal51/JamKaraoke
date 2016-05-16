//
//  KaraokeViewController.swift
//  JamKaraoke
//
//  Created by Jamaal Sedayao on 5/12/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import UIKit
import AVFoundation

class KaraokeViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var noteImageView1: UIImageView!
    @IBOutlet weak var noteImageView2: UIImageView!
    @IBOutlet weak var lyricsLabel: UILabel!
    
    var timer = NSTimer()
    
    var selectedSong: [String:AnyObject]!
    var songName: String!
    var songPath: NSURL!
    var lyricsArray: [String]!
    var songTime = String()
    var songTimeTotal = NSTimeInterval()
    var lyricsTimeDict = [String:String]()

//    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var videoLayer = AVCaptureVideoPreviewLayer()
    
    var songPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        songName = selectedSong.removeValueForKey("songName")! as! String
        title = String(songName!)
        songPath = selectedSong.removeValueForKey("songFile")! as! NSURL
        lyricsTimeDict = selectedSong.removeValueForKey("songLyrics")! as! [String:String]
        
        lyricsLabel.text = "TEST"
        
        showAlertController()
        startLiveVideo()
        
    }
    
    func startLiveVideo(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
           
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetHigh

            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            
            for device in devices {
                if(device.position == AVCaptureDevicePosition.Front){
                    captureDevice = device as? AVCaptureDevice
                }
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
            } catch {
                print("woops")
            }

            videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.frame = self.view.bounds
            
            cameraView.layer.addSublayer(videoLayer)
            self.view.addSubview(cameraView)
            self.cameraView.addSubview(microphoneImageView)
            self.cameraView.addSubview(noteImageView1)
            self.cameraView.addSubview(noteImageView2)
            self.cameraView.addSubview(lyricsLabel) 
            captureSession.startRunning()
        }
        
    }
    
    func showAlertController() {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Ready To Sing?", style: .Default, handler:(playSong)))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: (backToList)))
        presentViewController(alert, animated: true, completion: nil)
        
    }

    func playSong(alert:UIAlertAction) {
      
        do{
            try songPlayer = AVAudioPlayer(contentsOfURL:songPath!)
        } catch {
            print("Woops")
        }
        songPlayer.play()
        
        //songTime = Double(songPlayer.duration)
        //songTimeTotal = songPlayer.duration
        
        songTimeTotal = 0.0
        
        timer = NSTimer(
            timeInterval: 1,
                  target: self,
                  selector: #selector(fireTimer),
                userInfo: nil,
                 repeats: true
        )
        
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        timer.fire()
    }
    
    func fireTimer(timer:NSTimer){
        let interval: NSTimeInterval = 1
        songTimeTotal += interval
        
        songTime = stringFromTimeInterval(songTimeTotal)
        
        changeLyricsLabel(songTime)
        
        print(songTime)
    }
    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func changeLyricsLabel(timeString:String) {
        print("passed")
        for lyricTime in lyricsTimeDict {
            if timeString == lyricTime.0{
                lyricsLabel.text = lyricTime.1
                lyricsTimeDict.removeValueForKey(lyricTime.0)
            }
        }
    }
    
    func backToList(alert:UIAlertAction) {
        songPlayer?.stop()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        songPlayer?.stop()
        timer.invalidate()
    }
}

