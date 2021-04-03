//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

protocol DataModelDelegate: class {
    func didRecieveDataUpdate(data: String)
}

class PomodoroModel {
    
    weak var delegate: DataModelDelegate?
    private var timer = Timer()
    private var timerBreak = Timer()
    private var count = 5
    private var countBreak = 3
    private var work = false
// 1500 300

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in self.countTimer() }
    }
    
    func countTimer() {
        
        if count > -1 {
            work = true
            delegate?.didRecieveDataUpdate(data: formatTime(time: count))
            count -= 1
        } else {
            work = false
        }
        
        if work == false {
            if countBreak > -1 {
                delegate?.didRecieveDataUpdate(data: formatTime(time: countBreak))
                countBreak -= 1
            } else {
                reset()
                startTimer()
            }
        }
        
    }
    
    func formatTime(time: Int) -> String {
        
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    func reset() {
        timer.invalidate()
        count = 5
        countBreak = 3
    }
    
    func pause() {
        timer.invalidate()
    }
}
