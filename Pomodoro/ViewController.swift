//
//  ViewController.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import UIKit

class ViewController: UIViewController, PomodoroModelDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var numberOfCyclesLabel: UILabel!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.model = PomodoroModel()
        self.model.delegate = self
        self.remainingTimeLabel.text = ViewController.formatTime(self.model.workTimeInterval)
    }
 
    @IBAction func onStartButton(_ sender: UIButton) {
        model.start()
    }
    
    @IBAction func onPauseButton(_ sender: UIButton) {
        model.suspend()
    }
    
    @IBAction func onContinueButton(_ sender: UIButton) {
        model.resume()
    }
    
    @IBAction func onStopButton(_ sender: UIButton) {
        model.stop()
    }
    
    // MARK: PomodoroModelDelegate
    func didStartWork(sliceNumber: UInt, remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds, textColor: UIColor.red)
        updateNumberOfCyclesLabel(slices: sliceNumber)
        didResumeWork()
    }
    
    func continueWork(remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds)
    }
    
    func didStartBreak(remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds, textColor: UIColor.green)
    }
    
    func continueBreak(remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds)
    }
    
    func didStartRest(remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds, textColor: UIColor.yellow)
    }
    
    func continueRest(remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds)
    }
    
    func didSuspendWork() {
        startButton.isHidden = true
        pauseButton.isHidden = true
        continueButton.isHidden = false
        stopButton.isHidden = false
    }
    
    func didResumeWork() {
        startButton.isHidden = true
        pauseButton.isHidden = false
        continueButton.isHidden = true
        stopButton.isHidden = false
    }
    
    func didStopWork() {
        startButton.isHidden = false
        pauseButton.isHidden = true
        continueButton.isHidden = true
        stopButton.isHidden = true
        self.remainingTimeLabel.text = ViewController.formatTime(self.model.workTimeInterval)
    }
    
    // MARK: Private
    private var model: PomodoroModel!
    
    private func updateNumberOfCyclesLabel(slices: UInt) {
        self.numberOfCyclesLabel.text = String(slices)
    }
    
    private func updateRemainingTimeLabel(count: UInt, textColor: UIColor? = nil) {
        self.remainingTimeLabel.text = Self.formatTime(count)
        if let textColor = textColor {
            self.remainingTimeLabel.textColor = textColor
        }
    }

    private class func formatTime(_ secondCount: UInt) -> String {

        let minutes = Int(secondCount) / 60 % 60
        let seconds = Int(secondCount) % 60

        return String(format: "%02i:%02i", minutes, seconds)
    }
}
