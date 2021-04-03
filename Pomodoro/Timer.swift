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
    
    private var timer = Timer()
    private var timerBreak = Timer()
    private var count = 5
    private var countBreak = 3
    private var work = false
// 1500 300

    func startTimer(completion: @escaping ((_ data: String) -> Void)) {
        
//       !!! let completion: (String) -> Void !!!
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            if self.count > -1 {
                self.work = true
                
                completion(self.formatTime(time: self.count))
                
                self.count -= 1
            } else {
            self.work = false
            }
        
            if self.work == false {
                if self.countBreak > -1 {

                    completion(self.formatTime(time: self.countBreak))
                    
                self.countBreak -= 1
            } else {
                self.reset()
//                completion(nil) !!!
//                self.startTimer(completion: <#T##((String) -> Void)##((String) -> Void)##(String) -> Void#>) !!!
            }
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
