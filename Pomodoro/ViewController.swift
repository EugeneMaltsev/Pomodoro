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
    
    @IBOutlet weak var changeWorkTimeButtonOutlet: UIButton!
    @IBOutlet weak var changeBreakTimeButtonOutlet: UIButton!
    @IBOutlet weak var changeRestTimeButtonOutlet: UIButton!
    @IBOutlet weak var changeNumberOfCyclesButtonOutlet: UIButton!
    
    @IBOutlet weak var countDownWorkPicker: UIDatePicker!
    @IBOutlet weak var countDownWorkPickerToolbar: UIToolbar!
    
    @IBOutlet weak var countDownBreakPicker: UIDatePicker!
    @IBOutlet weak var countDownBreakPickerToolbar: UIToolbar!
    
    @IBOutlet weak var countDownRestPicker: UIDatePicker!
    @IBOutlet weak var countDownRestPickerToolbar: UIToolbar!
    
    @IBAction func changeNumberoOfCyclesButton(_ sender: UIButton) {
    }

    @IBAction func changeWorkTimeButton(_ sender: UIButton) {
        if countDownWorkPicker.isHidden {
            countDownWorkPicker.isHidden = false
        }
        if countDownWorkPickerToolbar.isHidden {
            countDownWorkPickerToolbar.isHidden = false
        }
        changeRestTimeButtonOutlet.isEnabled = false
        changeBreakTimeButtonOutlet.isEnabled = false
        
        countDownWorkPicker.datePickerMode = .countDownTimer
        countDownWorkPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissWorkPicker))
        countDownWorkPickerToolbar.setItems([space, doneButton], animated: false)
        countDownWorkPicker.countDownDuration = TimeInterval(self.model.workTimeInterval)
        self.model.workTimeInterval = PomodoroModel.TimeInterval(countDownWorkPicker.countDownDuration)
        changeWorkTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownWorkPicker.countDownDuration)))", for: .normal)
        countDownWorkPicker.addTarget(self, action: #selector(changeWorkProperty), for: .valueChanged )
    }
    
    @IBAction func changeBreakTimeButton(_ sender: UIButton) {
        if countDownBreakPicker.isHidden {
            countDownBreakPicker.isHidden = false
        }
        if countDownBreakPickerToolbar.isHidden {
            countDownBreakPickerToolbar.isHidden = false
        }
        changeWorkTimeButtonOutlet.isEnabled = false
        changeRestTimeButtonOutlet.isEnabled = false

        countDownBreakPicker.datePickerMode = .countDownTimer
        countDownBreakPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissBreakPicker))
        countDownBreakPickerToolbar.setItems([space, doneButton], animated: false)
        countDownBreakPicker.countDownDuration = TimeInterval(self.model.breakTimeInterval)
        self.model.breakTimeInterval = PomodoroModel.TimeInterval(countDownBreakPicker.countDownDuration)
        changeBreakTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownBreakPicker.countDownDuration)))", for: .normal)
        countDownBreakPicker.addTarget(self, action: #selector(changeBreakProperty), for: .valueChanged )
    }
    
    @IBAction func changeRestTimeButton(_ sender: UIButton) {
        if countDownRestPicker.isHidden {
            countDownRestPicker.isHidden = false
        }
        if countDownRestPickerToolbar.isHidden {
            countDownRestPickerToolbar.isHidden = false
        }
        changeWorkTimeButtonOutlet.isEnabled = false
        changeBreakTimeButtonOutlet.isEnabled = false

        countDownRestPicker.datePickerMode = .countDownTimer
        countDownRestPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissRestPicker))
        countDownRestPickerToolbar.setItems([space, doneButton], animated: false)
        countDownRestPicker.countDownDuration = TimeInterval(self.model.restTimeInterval)
        self.model.restTimeInterval = PomodoroModel.TimeInterval(countDownRestPicker.countDownDuration)
        changeRestTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownRestPicker.countDownDuration)))", for: .normal)
        countDownRestPicker.addTarget(self, action: #selector(changeRestProperty), for: .valueChanged )
    }
    
    @objc public func changeWorkProperty() {
        self.model.workTimeInterval = PomodoroModel.TimeInterval(countDownWorkPicker.countDownDuration)
        changeWorkTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownWorkPicker.countDownDuration)))", for: .normal)
    }
    
    @objc public func changeBreakProperty() {
        self.model.breakTimeInterval = PomodoroModel.TimeInterval(countDownBreakPicker.countDownDuration)
        changeBreakTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownBreakPicker.countDownDuration)))", for: .normal)
    }

    @objc public func changeRestProperty() {
        self.model.restTimeInterval = PomodoroModel.TimeInterval(countDownRestPicker.countDownDuration)
        changeRestTimeButtonOutlet.setTitle("\(Self.formatTimeButton(UInt(countDownRestPicker.countDownDuration)))", for: .normal)
    }

//    @objc public func changeWorkProperty() {
//        self.model.workTimeInterval = PomodoroModel.TimeInterval(countDownWorkPicker.countDownDuration)
//        changeWorkTimeButtonOutlet.setTitle("\(Self.formatTime(UInt(countDownWorkPicker.countDownDuration)))", for: .normal)
//    }

    @objc public func dismissWorkPicker() {
        changeRestTimeButtonOutlet.isEnabled = true
        changeBreakTimeButtonOutlet.isEnabled = true

        countDownWorkPicker.isHidden = true
        countDownWorkPickerToolbar.isHidden = true
        updateRemainingTimeLabel(count: model.workTimeInterval)
    }
    @objc public func dismissBreakPicker() {
        changeWorkTimeButtonOutlet.isEnabled = true
        changeRestTimeButtonOutlet.isEnabled = true

        countDownBreakPicker.isHidden = true
        countDownBreakPickerToolbar.isHidden = true
//        updateRemainingTimeLabel(count: model.breakTimeInterval)

    }

    @objc public func dismissRestPicker() {
        changeWorkTimeButtonOutlet.isEnabled = true
        changeBreakTimeButtonOutlet.isEnabled = true
        
        countDownRestPicker.isHidden = true
        countDownRestPickerToolbar.isHidden = true
//        updateRemainingTimeLabel(count: model.restTimeInterval)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = PomodoroModel()
        self.model.delegate = self
        self.remainingTimeLabel.text = ViewController.formatTime(self.model.workTimeInterval)
        self.changeWorkTimeButtonOutlet.setTitle("\(Self.formatTimeButton(model.workTimeInterval))", for: .normal)
        self.changeRestTimeButtonOutlet.setTitle("\(Self.formatTimeButton(model.restTimeInterval))", for: .normal)
        self.changeBreakTimeButtonOutlet.setTitle("\(Self.formatTimeButton(model.breakTimeInterval))", for: .normal)

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
    private class func formatTimeButton(_ secondCount: UInt) -> String {

        let minutes = Int(secondCount) / 60 % 60
//        let seconds = Int(secondCount) % 60

//        return String(format: "%02i", minutes, seconds)
        return String(format: "%2i", minutes)

    }

}
