//
//  ViewController.swift
//  VoiceRecognition
//https://developer.apple.com/library/prerelease/content/samplecode/SpeakToMe/Listings/SpeakToMe_ViewController_swift.html
//  Created by Emmanuel Erilibe on 11/27/16.
//  Copyright © 2016 Emmanuel Erilibe. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
   
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var recordLabel: UILabel!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = false
        activitySpinner.isHidden = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in

            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordLabel.text = "User denied!"
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordLabel.text = "User denied!"
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordLabel.text = "User denied!"
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordLabel.text = "Start Recording!"
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
        
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordLabel.text = "Start Recording!"
        } else {
            recordButton.isEnabled = false
            recordLabel.text = "Recognition not available!"
        }
    }
    
    @IBAction func recordButtonPressed() {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordLabel.text = "Stopping"
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
        } else {
            try! startRecording()
            recordLabel.text = "Stop recording"
        }
    }
}





