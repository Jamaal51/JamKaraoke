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

enum RecordButton {
    case Play
    case Stop
}

class KaraokeViewController: UIViewController, RPPreviewViewControllerDelegate{
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var noteImageView1: UIImageView!
    @IBOutlet weak var noteImageView2: UIImageView!
    @IBOutlet weak var lyricsLabel: UILabel?
    @IBOutlet weak var stopAndSaveButton: UIButton!
    
    var timer = NSTimer()
    var selectedSong: [String:AnyObject]!
    var songName: String!
    var songPath: NSURL!
    var lyricsArray: [String]?
    var songTime = String()
    var songTimeTotal = NSTimeInterval()
    var lyricsTimeDict = [String:String]()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(stopRecording))
        
        startLiveVideo()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            self.startRecording()
        }
        
        
    }
    
    func prepareAudioToPlay(){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)){
            do{
                try self.songPlayer = AVAudioPlayer(contentsOfURL:self.songPath!)
            } catch {
                print("Woops")
            }
            self.songPlayer!.prepareToPlay()
            self.songPlayer!.settings
            
            self.songPlayer!.play()
            
            
        }
        startTimer()
    }
    
    // MARK: Replay Kit Methods
    
    @IBAction func stopAndSaveTapped(sender: UIBarButtonItem) {
        
        stopRecording()
        
    }
    
    func startRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.startRecordingWithMicrophoneEnabled(true) {(error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                print("called")
                self.prepareAudioToPlay()
                //print(recorder.microphoneEnabled.boolValue)
            }
        }
        
    }
    
    func stopRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { [unowned self] (preview, error) in
            if let previewView = preview {
                previewView.previewControllerDelegate = self
                self.presentViewController(previewView, animated: true, completion: nil)
            }
        }
    }
    
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
//    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
//        navigationController?.dismissViewControllerAnimated(true, completion: {
//            self.navigationController?.popToRootViewControllerAnimated(true)
//        })
//    }
    
    
    // MARK - ImagePicker
    
    func startLiveVideo(){
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                
                let captureSession = AVCaptureSession()
                captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540
                
                let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                let deviceAudio = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
                
                for device in devices {
                    if(device.position == AVCaptureDevicePosition.Front){
                        self.captureDevice = device as? AVCaptureDevice
                    }
                }
                
                
                do {
                    let input = try AVCaptureDeviceInput(device: self.captureDevice)
                    captureSession.addInput(input)
                
                } catch {
                    print("woops no Video")
                }
                
                do {
                    let input = try AVCaptureDeviceInput(device: deviceAudio)
                    captureSession.addInput(input)
                } catch {
                    print("woops no Audio")
                }
                
                captureSession.startRunning()
                
                self.videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
                dispatch_async(dispatch_get_main_queue()){
                    self.videoLayer.frame = self.view.bounds
                    self.cameraView.clipsToBounds = true
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
    
    func startTimer() {
        
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
        
        let recording = RPScreenRecorder.sharedRecorder()
        
        recording.stopRecordingWithHandler { (preview, error) in
            recording.discardRecordingWithHandler({ 
                self.navigationController?.popToRootViewControllerAnimated(true)
                print("called stop and discard")
            })
        }
        
        //navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        songPlayer?.stop()
        timer.invalidate()
        
        let recording = RPScreenRecorder.sharedRecorder()
        
        recording.stopRecordingWithHandler { (preview, error) in
            recording.discardRecordingWithHandler({
                print("called stop and discard")
            })
        }

        
    }
}

