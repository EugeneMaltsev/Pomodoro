//
//  ViewController.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        guard model == nil else { return }
        
        startButton.isHidden = true
        pauseButton.isHidden = false
        stopButton.isHidden = true
        
        model = .init()
        model.workTimeHandler = { [weak self] elpsedTime in
            self?.handleElapsedWorkTime(elpsedTime)
        }
        model.breakTimeHandler = { [weak self] elpsedTime in
            self?.handleElapsedBreakTime(elpsedTime)
        }
        model.start()
    }
    
    
    @IBAction func pauseButton(_ sender: UIButton) {
        // TODO: model.pause()
        
        startButton.isHidden = false
        pauseButton.isHidden = true
        stopButton.isHidden = false
    }
    
    
    @IBAction func stopButton(_ sender: UIButton) {

        // TODO: model.reset()

        stopButton.isHidden = true
        startButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    // MARK: Private
    private var model: PomodoroModel!
    
    private func handleElapsedWorkTime(_ elapsedTime: PomodoroModel.TimeInterval) {
        remainingTimeLabel.text = Self.formatTime(time: elapsedTime)
    }

    private func handleElapsedBreakTime(_ elapsedTime: PomodoroModel.TimeInterval) {
        remainingTimeLabel.text = Self.formatTime(time: elapsedTime)
    }
    
    private class func formatTime(time: PomodoroModel.TimeInterval) -> String {

        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format: "%02i:%02i", minutes, seconds)
    }
}
