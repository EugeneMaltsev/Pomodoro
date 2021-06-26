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
    
    @IBOutlet weak var workTimeIntervalCustomizeButton: UIButton!
    @IBOutlet weak var breakTimeIntervalCustomizeButton: UIButton!
    @IBOutlet weak var restTimeIntervalCustomizeButton: UIButton!
    @IBOutlet weak var numberOfCyclesCustomizeButton: UIButton!
    
    @IBOutlet weak var workTimeIntervalPicker: UIDatePicker!
    @IBOutlet weak var toolbarOfWorkTimeIntervalPicker: UIToolbar!
    
    @IBOutlet weak var breakTimeIntervalPicker: UIDatePicker!
    @IBOutlet weak var toolbarOfBreakTimeIntervalPicker: UIToolbar!
    
    @IBOutlet weak var restTimeIntervalPicker: UIDatePicker!
    @IBOutlet weak var toolbarOfRestTimeIntervalPicker: UIToolbar!
    
    @IBOutlet weak var numberOfCyclesPicker: UIPickerView!
    
    @IBAction func changeNumberOfCyclesButton(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = PomodoroModel()
        self.model.delegate = self
        self.remainingTimeLabel.text = ViewController.formatTimeForLabel(self.model.workTimeInterval)
        self.workTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(model.workTimeInterval))", for: .normal)
        self.restTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(model.restTimeInterval))", for: .normal)
        self.breakTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(model.breakTimeInterval))", for: .normal)
    }
    
    @IBAction func setWorkTimeIntervalAction(_ sender: UIButton) {
        if workTimeIntervalPicker.isHidden {
            workTimeIntervalPicker.isHidden = false
        }
        if toolbarOfWorkTimeIntervalPicker.isHidden {
            toolbarOfWorkTimeIntervalPicker.isHidden = false
        }
        restTimeIntervalCustomizeButton.isEnabled = false
        breakTimeIntervalCustomizeButton.isEnabled = false
        
        workTimeIntervalPicker.datePickerMode = .countDownTimer
        workTimeIntervalPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissWorkTimeIntervalPickerANDtoolbarOfWorkTimeIntervalPicker))
        toolbarOfWorkTimeIntervalPicker.setItems([space, doneButton], animated: false)
        workTimeIntervalPicker.countDownDuration = TimeInterval(self.model.workTimeInterval)
        self.model.workTimeInterval = PomodoroModel.TimeInterval(workTimeIntervalPicker.countDownDuration)
        workTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(workTimeIntervalPicker.countDownDuration)))", for: .normal)
        workTimeIntervalPicker.addTarget(self, action: #selector(workTimeIntervalPickerIsChanged), for: .valueChanged )
    }
    
    @IBAction func setBreakTimeIntervalAction(_ sender: UIButton) {
        if breakTimeIntervalPicker.isHidden {
            breakTimeIntervalPicker.isHidden = false
        }
        if toolbarOfBreakTimeIntervalPicker.isHidden {
            toolbarOfBreakTimeIntervalPicker.isHidden = false
        }
        workTimeIntervalCustomizeButton.isEnabled = false
        restTimeIntervalCustomizeButton.isEnabled = false

        breakTimeIntervalPicker.datePickerMode = .countDownTimer
        breakTimeIntervalPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissBreakTimeIntervalPickerANDtoolbarOfBreakTimeIntervalPicker))
        toolbarOfBreakTimeIntervalPicker.setItems([space, doneButton], animated: false)
        breakTimeIntervalPicker.countDownDuration = TimeInterval(self.model.breakTimeInterval)
        self.model.breakTimeInterval = PomodoroModel.TimeInterval(breakTimeIntervalPicker.countDownDuration)
        breakTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(breakTimeIntervalPicker.countDownDuration)))", for: .normal)
        breakTimeIntervalPicker.addTarget(self, action: #selector(breakTimeIntervalPickerIsChanged), for: .valueChanged )
    }
    
    @IBAction func setRestTimeIntervalAction(_ sender: UIButton) {
        if restTimeIntervalPicker.isHidden {
            restTimeIntervalPicker.isHidden = false
        }
        if toolbarOfRestTimeIntervalPicker.isHidden {
            toolbarOfRestTimeIntervalPicker.isHidden = false
        }
        workTimeIntervalCustomizeButton.isEnabled = false
        breakTimeIntervalCustomizeButton.isEnabled = false

        restTimeIntervalPicker.datePickerMode = .countDownTimer
        restTimeIntervalPicker.center = view.center
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissRestTimeIntervalPickerANDtoolbarOfRestTimeIntervalPicker))
        toolbarOfRestTimeIntervalPicker.setItems([space, doneButton], animated: false)
        restTimeIntervalPicker.countDownDuration = TimeInterval(self.model.restTimeInterval)
        self.model.restTimeInterval = PomodoroModel.TimeInterval(restTimeIntervalPicker.countDownDuration)
        restTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(restTimeIntervalPicker.countDownDuration)))", for: .normal)
        restTimeIntervalPicker.addTarget(self, action: #selector(restTimeIntervalPickerIsChanged), for: .valueChanged )
    }
    
    @objc public func workTimeIntervalPickerIsChanged() {
        self.model.workTimeInterval = PomodoroModel.TimeInterval(workTimeIntervalPicker.countDownDuration)
        workTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(workTimeIntervalPicker.countDownDuration)))", for: .normal)
    }
    
    @objc public func breakTimeIntervalPickerIsChanged() {
        self.model.breakTimeInterval = PomodoroModel.TimeInterval(breakTimeIntervalPicker.countDownDuration)
        breakTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(breakTimeIntervalPicker.countDownDuration)))", for: .normal)
    }

    @objc public func restTimeIntervalPickerIsChanged() {
        self.model.restTimeInterval = PomodoroModel.TimeInterval(restTimeIntervalPicker.countDownDuration)
        restTimeIntervalCustomizeButton.setTitle("\(Self.formatTimeForCustomizeButtons(UInt(restTimeIntervalPicker.countDownDuration)))", for: .normal)
    }

    @objc public func dismissWorkTimeIntervalPickerANDtoolbarOfWorkTimeIntervalPicker() {
        restTimeIntervalCustomizeButton.isEnabled = true
        breakTimeIntervalCustomizeButton.isEnabled = true

        workTimeIntervalPicker.isHidden = true
        toolbarOfWorkTimeIntervalPicker.isHidden = true
        updateRemainingTimeLabel(count: model.workTimeInterval)
    }
    @objc public func dismissBreakTimeIntervalPickerANDtoolbarOfBreakTimeIntervalPicker() {
        workTimeIntervalCustomizeButton.isEnabled = true
        restTimeIntervalCustomizeButton.isEnabled = true

        breakTimeIntervalPicker.isHidden = true
        toolbarOfBreakTimeIntervalPicker.isHidden = true
    }
    @objc public func dismissRestTimeIntervalPickerANDtoolbarOfRestTimeIntervalPicker() {
        workTimeIntervalCustomizeButton.isEnabled = true
        breakTimeIntervalCustomizeButton.isEnabled = true
        
        restTimeIntervalPicker.isHidden = true
        toolbarOfRestTimeIntervalPicker.isHidden = true
    }
    
    func hideAllCustomizeButtons() {
        workTimeIntervalCustomizeButton.isEnabled = false
        breakTimeIntervalCustomizeButton.isEnabled = false
        restTimeIntervalCustomizeButton.isEnabled = false
        numberOfCyclesCustomizeButton.isEnabled = false
    }
    
    func showAllCustomizeButtons() {
        workTimeIntervalCustomizeButton.isEnabled = true
        breakTimeIntervalCustomizeButton.isEnabled = true
        restTimeIntervalCustomizeButton.isEnabled = true
        numberOfCyclesCustomizeButton.isEnabled = true
    }
    
    @IBAction func onStartButton(_ sender: UIButton) {
        model.start()
        hideAllCustomizeButtons()
    }
    
    @IBAction func onPauseButton(_ sender: UIButton) {
        model.suspend()
        showAllCustomizeButtons()
    }
    
    @IBAction func onContinueButton(_ sender: UIButton) {
        model.resume()
        hideAllCustomizeButtons()
    }
    
    @IBAction func onStopButton(_ sender: UIButton) {
        model.stop()
        showAllCustomizeButtons()
    }
    
    // MARK: PomodoroModelDelegate
    func didStartWork(partOfCompeletedCycle: UInt, remaningSeconds: UInt) {
        updateRemainingTimeLabel(count: remaningSeconds, textColor: UIColor.red)
        updateNumberOfCyclesLabel(cyclePart: partOfCompeletedCycle)
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
        self.remainingTimeLabel.text = ViewController.formatTimeForLabel(self.model.workTimeInterval)
    }
    
    // MARK: Private
    private var model: PomodoroModel!
    
    private func updateNumberOfCyclesLabel(cyclePart: UInt) {
        self.numberOfCyclesLabel.text = String(cyclePart)
    }
    
    private func updateRemainingTimeLabel(count: UInt, textColor: UIColor? = nil) {
        self.remainingTimeLabel.text = Self.formatTimeForLabel(count)
        if let textColor = textColor {
            self.remainingTimeLabel.textColor = textColor
        }
    }

    private class func formatTimeForLabel(_ secondCount: UInt) -> String {

        let minutes = Int(secondCount) / 60 % 60
        let seconds = Int(secondCount) % 60

        return String(format: "%02i:%02i", minutes, seconds)
    }
    private class func formatTimeForCustomizeButtons(_ secondCount: UInt) -> String {

        let minutes = Int(secondCount) / 60 % 60
        
        return String(format: "%2i", minutes)

    }

}
