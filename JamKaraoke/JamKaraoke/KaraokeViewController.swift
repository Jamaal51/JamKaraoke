//
//  KaraokeViewController.swift
//  JamKaraoke
//
//  Created by Jamaal Sedayao on 5/12/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import UIKit
import AVFoundation
import ReplayKit

class KaraokeViewController: UIViewController, RPPreviewViewControllerDelegate{
    
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
    
    var songPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        songName = selectedSong.removeValueForKey("songName") as! String
        title = String(songName)
        songPath = selectedSong.removeValueForKey("songFile") as! NSURL
        lyricsTimeDict = selectedSong.removeValueForKey("songLyrics") as! [String:String]
        
        lyricsLabel!.text = " "
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(startRecording))
        
        showAlertController()
        startLiveVideo()
    }
    
// MARK: Replay Kit Methods
    
    func startRecording() {
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)){
        
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.startRecordingWithMicrophoneEnabled(true) { [unowned self](error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(self.stopRecording))

            }
        }
        }
        
    }
    
    func stopRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { [unowned self] (preview, error) in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(self.startRecording))
            
            if let unwrappedPreview = preview {
                unwrappedPreview.previewControllerDelegate = self
                self.presentViewController(unwrappedPreview, animated: true, completion: nil)
            }
        }
        
    }
    
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
        
    }

    
// MARK - ImagePicker
    
    func startLiveVideo(){
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)){
           
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            
            for device in devices {
                if(device.position == AVCaptureDevicePosition.Front){
                    
                    self.captureDevice = device as? AVCaptureDevice
                }
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: self.captureDevice)
                captureSession.addInput(input)
            } catch {
                print("woops")
            }
            
            captureSession.startRunning()

            self.videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            dispatch_async(dispatch_get_main_queue()){ //
                self.videoLayer.frame = self.view.bounds
                self.cameraView.layer.addSublayer(self.videoLayer)
                self.view.addSubview(self.cameraView)
                self.cameraView.addSubview(self.microphoneImageView)
                self.cameraView.addSubview(self.noteImageView1)
                self.cameraView.addSubview(self.noteImageView2)
                self.cameraView.addSubview(self.lyricsLabel!)
            }
        }
        
    }
        
}
    
    func showAlertController() {
        let alert = UIAlertController(title: "Ready To Sing?", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Yes!", style: .Default, handler:(playSong)))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: (backToList)))
        presentViewController(alert, animated: true, completion: nil)
        
    }

    func playSong(alert:UIAlertAction) {
      
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0)){
        
        do{
            try self.songPlayer = AVAudioPlayer(contentsOfURL:self.songPath!)
        } catch {
            print("Woops")
        }
        
        self.songPlayer!.play()
            
        }
        
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
        
        for lyricTime in lyricsTimeDict {
            if timeString == lyricTime.0{
                lyricsLabel!.text = lyricTime.1
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

