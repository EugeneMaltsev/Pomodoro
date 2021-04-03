//
//  ViewController.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import UIKit


class ViewController: UIViewController, DataModelDelegate {
    
    func didRecieveDataUpdate(data: String) {
        stopWatchAction.text = data
    }
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var stopWatchAction: UILabel!
    
    var timer = PomodoroModel()
    
    @IBAction func startButton(_ sender: UIButton) {
        
        timer.delegate = self
        timer.startTimer()

        startButton.isHidden = true
        pauseButton.isHidden = false
        stopButton.isHidden = true
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        
        timer.pause()
        
        startButton.isHidden = false
        pauseButton.isHidden = true
        stopButton.isHidden = false
    }
    
    
    @IBAction func stopButton(_ sender: UIButton) {

        timer.reset()

        stopButton.isHidden = true
        startButton.isHidden = false
        pauseButton.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        }
}

