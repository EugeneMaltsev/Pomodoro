//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

public class PomodoroModel {
    
    public typealias TimeInterval = UInt
    public typealias TimeHandler = (TimeInterval) -> Void
    
    public var workTimeHandler: TimeHandler?
    public var breakTimeHandler: TimeHandler?
    
    init(workTimeInterval: TimeInterval = 1500, breakTimeInterval: TimeInterval = 300) {
        self.workTimeInterval = workTimeInterval
        self.breakTimeInterval = breakTimeInterval
    }

    func start() {
        assert(timer == nil)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.timer == timer else { return }
            
            if self.work {
                assert(self.workTimeInterval > 0)
                self.workTimeInterval -= 1
                self.workTimeHandler?(self.workTimeInterval)
                if self.workTimeInterval == 0 {
                    self.work = false
                }
            } else {
                assert(self.breakTimeInterval > 0)
                self.breakTimeInterval -= 1
                self.breakTimeHandler?(self.breakTimeInterval)
                if self.breakTimeInterval == 0 {
                    timer.invalidate()
                    self.timer = nil
                }
            }
        }
    }

    private var timer: Timer?
    private var workTimeInterval: TimeInterval
    private var breakTimeInterval: TimeInterval
    private var work = true
    
//    func reset() {
//        timer.invalidate()
//        count = 5
//        countBreak = 3
//    }
//
//    func pause() {
//        timer.invalidate()
//    }
}
