//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

public protocol PomodoroDelegate: class {
    func workTime(data : UInt)
    func breakTime(data: UInt)
    func restTime(data: UInt)
}


public class PomodoroModel {
    
    public typealias TimeInterval = UInt
    public typealias TimeHandler = (TimeInterval) -> Void
    
    weak var delegate: PomodoroDelegate?
    
    public var workTimeHandler: TimeHandler?
    public var breakTimeHandler: TimeHandler?
    public var restTimeHandler: TimeHandler?
    public var tomatoSlice: TimeInterval = 0
    
    init( workTimeInterval: TimeInterval = 3,
          breakTimeInterval: TimeInterval = 2,
          restTimeInterval: TimeInterval = 15,
          numberOfCycles: TimeInterval = 4) {
        
        
        self.workTimeInterval = workTimeInterval
        self.breakTimeInterval = breakTimeInterval
        self.restTimeInterval = restTimeInterval
        self.numberOfPomodoroCycles = numberOfCycles
    }
    
    func start() {
        assert(timer == nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.timer == timer else { return }
            
            
            assert(self.workTimeInterval > 0)
            self.workTimeInterval -= 1
            self.workTimeHandler?(self.workTimeInterval)
//            self.delegate?.workTime(data: self.workTimeInterval)
            if self.workTimeInterval == 0 {
                timer.invalidate()
                self.timer = nil
                self.workTimeInterval = 3
                self.breakStart()
            }
        }
    }
    
    func breakStart() {
        assert(timer == nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.timer == timer else { return }
            
            assert(self.breakTimeInterval > 0)
            self.breakTimeInterval -= 1
            self.breakTimeHandler?(self.breakTimeInterval)
//            self.delegate?.breakTime(data: self.breakTimeInterval)
            if self.breakTimeInterval == 0 {
                self.numberOfPomodoroCycles -= 1
                self.tomatoSlice += 1
                if self.numberOfPomodoroCycles == 0{
                    timer.invalidate()
                    self.timer = nil
                    self.breakTimeInterval = 2
                    self.startRest()
                } else {
                    timer.invalidate()
                    self.timer = nil
                    self.breakTimeInterval = 2
                    self.start()
                }
            }
        }
    }
    
    func startRest() {
        assert(timer == nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.timer == timer else { return }
            
            
            assert(self.restTimeInterval > 0)
            self.restTimeInterval -= 1
            self.restTimeHandler?(self.restTimeInterval)
//            self.delegate?.restTime(data: self.restTimeInterval)
            if self.restTimeInterval == 0 {
                timer.invalidate()
                self.timer = nil
                self.restTimeInterval = 15
                self.numberOfPomodoroCycles = 4
                self.start()
            }
        }
    }
    
//
//    func start() {
//        assert(timer == nil)
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let self = self else { return }
//            guard self.timer == timer else { return }
//
//            if self.work {
//                assert(self.workTimeInterval > 0)
//                self.workTimeInterval -= 1
//                self.workTimeHandler?(self.workTimeInterval)
//                if self.workTimeInterval == 0 {
//                    self.work = false
//                }
//            } else {
//                assert(self.breakTimeInterval > 0)
//                self.breakTimeInterval -= 1
//                self.breakTimeHandler?(self.breakTimeInterval)
//                if self.breakTimeInterval == 0 {
//                    timer.invalidate()
//                    self.timer = nil
//                }
//            }
//        }
//    }
    
    private var timer: Timer?
    private var workTimeInterval: TimeInterval
    private var breakTimeInterval: TimeInterval
    private var restTimeInterval: TimeInterval
    private var numberOfPomodoroCycles: TimeInterval
    
    
    func reset() {
        self.timer = nil
        timer?.invalidate()
        self.workTimeInterval = 3
        self.breakTimeInterval = 2
        self.restTimeInterval = 15
        
    }

    func pause() {
        timer?.invalidate()
    }
}

