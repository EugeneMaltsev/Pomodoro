//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

public protocol PomodoroModelDelegate: class {
    func didStartWork(sliceNumber: UInt, remaningSeconds: UInt)
    func continueWork(remaningSeconds: UInt)
    func didStartBreak(remaningSeconds: UInt)
    func continueBreak(remaningSeconds: UInt)
    func didStartRest(remaningSeconds: UInt)
    func continueRest(remaningSeconds: UInt)
    func didSuspendWork()
    func didResumeWork()
    func didStopWorks()
}

public class PomodoroModel {
    
    public typealias TimeInterval = UInt
    
    weak var delegate: PomodoroModelDelegate?
    
    let workTimeInterval: TimeInterval
    let breakTimeInterval: TimeInterval
    let restTimeInterval: TimeInterval
    let numberOfCycles: TimeInterval

    init(workTimeInterval: TimeInterval = 3,
         breakTimeInterval: TimeInterval = 2,
         restTimeInterval: TimeInterval = 15,
         numberOfCycles: TimeInterval = 4) {
        self.workTimeInterval = workTimeInterval
        self.breakTimeInterval = breakTimeInterval
        self.restTimeInterval = restTimeInterval
        self.numberOfCycles = numberOfCycles
        self.state = StateNeutral()
        self.state.model = self
    }
    
    func start() {
        state.start()
    }
    
    func stop() {
        state.stop()
    }
    
    func suspend() {
        state.suspend()
    }
    
    func resume() {
        state.resume()
    }
    
    // MARK: Private
    private var state: BaseState
}

private extension PomodoroModel {
    
    func switchState(_ state: BaseState) {
        assert(self.state !== state)
        self.state = state
        state.model = self
        self.state.didEnter()
    }
}

private extension PomodoroModel {
    
    class BaseState {
        
        weak var model: PomodoroModel?
        
        func didEnter() {
        }
                
        func start() {
            unexpectedCall()
        }
        
        func stop() {
            unexpectedCall()
        }
        
        func suspend() {
            unexpectedCall()
        }
        
        func resume() {
            unexpectedCall()
        }
        
        func unexpectedCall() {
            assertionFailure("Unexpected call")
        }
    }
}

private extension PomodoroModel {
    
    class StateNeutral: BaseState {
        
        override func start() {
            self.model?.switchState(StateActive())
        }
    }
}

private extension PomodoroModel {
    
    class StateActive: BaseState {
        
        override func didEnter() {
            assertionFailure("Not implemented")
        }
        
        override func stop() {
            
        }
        
        override func suspend() {
            
        }
        
        func suspendTimer() {
            
        }
        
        func resumeTimer() {
            
        }
    }
}

private extension PomodoroModel {
    
    class StateSuspended: BaseState {
        
        var activeState: StateActive
        
        init(activeState: StateActive) {
            self.activeState = activeState
        }
        
        override func didEnter() {
            self.activeState.suspendTimer()
        }
        
        override func stop() {
            self.activeState.stop()
        }
        
        override func resume() {
            self.model?.state = self.activeState
            self.activeState.resumeTimer()
        }
    }
}

/*
public class PomodoroModel {
    
    public typealias TimeInterval = UInt
    public typealias TimeHandler = (TimeInterval) -> Void
    
    weak var delegate: PomodoroDelegate?
    
    public var workTimeHandler: TimeHandler?
    public var breakTimeHandler: TimeHandler?
    public var restTimeHandler: TimeHandler?
    public var tomatoSlice: UInt = 0
    
    init(workTimeInterval: TimeInterval = 3,
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
    
    private func breakStart() {
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
                    self.resetTimer()
                    self.breakTimeInterval = 2
                    self.startRest()
                } else {
                    self.resetTimer()
                    self.breakTimeInterval = 2
                    self.start()
                }
            }
        }
    }
    
    private func startRest() {
        assert(timer == nil)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard self.timer == timer else { return }
            
            
            assert(self.restTimeInterval > 0)
            self.restTimeInterval -= 1
            self.restTimeHandler?(self.restTimeInterval)
//            self.delegate?.restTime(data: self.restTimeInterval)
            if self.restTimeInterval == 0 {
                self.resetTimer()
                self.restTimeInterval = 15
                self.numberOfPomodoroCycles = 4
                self.start()
            }
        }
    }
    
    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private var timer: Timer?
    private var workTimeInterval: TimeInterval
    private var breakTimeInterval: TimeInterval
    private var restTimeInterval: TimeInterval
    private var numberOfPomodoroCycles: TimeInterval
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
    

    
    
//    func reset() {
//        timer?.invalidate()
//        self.timer = nil
//        self.workTimeInterval = 3
//        self.breakTimeInterval = 2
//        self.restTimeInterval = 15
//
//    }
//
//    func pause() {
//        timer?.invalidate()
//    }
}
*/
