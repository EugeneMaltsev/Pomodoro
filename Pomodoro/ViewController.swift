//
//  ViewController.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import UIKit


class ViewController: UIViewController {

    var timer = Timer()
    var timerBreak = Timer()
    var count = 1500
    var countBreak = 300

    var work = false
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var stopWatchAction: UILabel!
    
    
    @IBAction func startButton(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(countTimer),
                                     userInfo: nil, repeats: true)
        startButton.isHidden = true
        pauseButton.isHidden = false
        stopButton.isHidden = true
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        timer.invalidate()
        startButton.isHidden = false
        pauseButton.isHidden = true
        stopButton.isHidden = false
    }
    
    
    @IBAction func stopButton(_ sender: UIButton) {
        reset()
        stopButton.isHidden = true
        startButton.isHidden = false
        pauseButton.isHidden = true
    }

    func reset() {
        timer.invalidate()
        count = 1500
        countBreak = 300
        stopWatchAction.text = formatTime(time: count)
    }
    
    @objc func countTimer() {
        
        if count > -1 {
            work = true
            stopWatchAction.text = formatTime(time: count)
            count -= 1
        } else {
            work = false
        }
        
        if work == false {
            if countBreak > -1 {
                stopWatchAction.text = formatTime(time: countBreak)
                countBreak -= 1
            } else {
                reset()
                startButton(startButton)
            }
        }
    }
    
    func formatTime(time: Int) -> String {
        
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}

