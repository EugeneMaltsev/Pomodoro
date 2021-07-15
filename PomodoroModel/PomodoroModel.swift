//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

public protocol PomodoroModelDelegate: class {
    func didStartWork(partOfCompeletedCycle: UInt, remaningSeconds: UInt)
    func continueWork(remaningSeconds: UInt)
    func didStartBreak(remaningSeconds: UInt)
    func continueBreak(remaningSeconds: UInt)
    func didStartRest(remaningSeconds: UInt)
    func continueRest(remaningSeconds: UInt)
    func didSuspendWork()
    func didResumeWork()
    func didStopWork()
}

// MARK: -

public class PomodoroModel {
    
    public typealias TimeInterval = UInt
    
    public weak var delegate: PomodoroModelDelegate?
    
    public let workTimeInterval: TimeInterval
    public let breakTimeInterval: TimeInterval
    public let restTimeInterval: TimeInterval
    public let numberOfCycles: TimeInterval

    public init(workTimeInterval: TimeInterval = 1500,
         breakTimeInterval: TimeInterval = 300,
         restTimeInterval: TimeInterval = 700,
         numberOfCycles: TimeInterval = 4) {
        self.workTimeInterval = workTimeInterval
        self.breakTimeInterval = breakTimeInterval
        self.restTimeInterval = restTimeInterval
        self.numberOfCycles = numberOfCycles
        self.state = StateNeutral()
        self.state.model = self
    }
    
    public func start() {
        state.start()
    }
    
    public func stop() {
        state.stop()
    }
    
    public func suspend() {
        state.suspend()
    }
    
    public func resume() {
        state.resume()
    }
    
    // MARK: Private
    private var state: BaseState
    private var timer: Timer?
}

// MARK: - SwitchState

private extension PomodoroModel {
    
    func switchState(_ state: BaseState) {
        assert(self.state !== state)
        self.state = state
        state.model = self
        self.state.didEnter()
    }
}

// MARK: - Timer

private extension PomodoroModel {
    
    class Timer {
        
        var fireBlock: (() -> Void)?
        
        deinit {
            self.underlyingTimer?.invalidate()
        }
        
        func suspend() {
            assert(self.underlyingTimer != nil)
            self.underlyingTimer?.invalidate()
            self.underlyingTimer = nil
        }
        
        func resume() {
            assert(self.underlyingTimer == nil)
            self.underlyingTimer = UnderlyingTimer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.fireBlock?()
            }
        }
        
        private typealias UnderlyingTimer = Foundation.Timer
        private var underlyingTimer: UnderlyingTimer?
    }
}

// MARK: - BaseState

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

// MARK: - StateActive

private extension PomodoroModel {
    
    class StateActive: BaseState {
        
        let timer = Timer()
        
        override func didEnter() {
            assert(self.substate == .working)
            guard let model = self.model else { return }
            self.remaningSeconds = model.workTimeInterval
            self.remaningCycles = model.numberOfCycles
            self.timer.fireBlock = { [weak self] in
                self?.timerDidFire()
            }
            self.timer.resume()
            model.delegate?.didStartWork(partOfCompeletedCycle: self.passedCycles, remaningSeconds: self.remaningSeconds)
        }
        
        override func stop() {
            guard let model = self.model else { return }
            model.switchState(StateNeutral())
            model.delegate?.didStopWork()
        }
        
        override func suspend() {
            self.model?.switchState(StateSuspended(activeState: self))
        }
        
        private enum Substate {
            case working
            case interrupt
            case rest
        }
        
        private var substate = Substate.working
        private var remaningSeconds = UInt(0)
        private var remaningCycles = UInt(0)
        private var passedCycles = UInt(0)

        private func timerDidFire() {
            assert(self.remaningSeconds > 0)
            self.remaningSeconds -= 1
            if self.remaningSeconds > 0 {
                self.continueSubstate()
            } else {
                self.switchToNextSubstate()
            }
        }
        
        private func continueSubstate() {
            assert(self.remaningSeconds > 0)
            switch self.substate {
            case .working:
                self.model?.delegate?.continueWork(remaningSeconds: self.remaningSeconds)
            case .interrupt:
                self.model?.delegate?.continueBreak(remaningSeconds: self.remaningSeconds)
            case .rest:
                self.model?.delegate?.continueRest(remaningSeconds: self.remaningSeconds)
            }
        }
 
        private func switchToNextSubstate() {
            assert(self.remaningSeconds == 0)
            guard let model = self.model else { return }
            switch self.substate {
            case .working:
                assert(self.remaningCycles > 0)
                self.remaningCycles -= 1
                self.passedCycles += 1
                if self.remaningCycles > 0 {
                    self.remaningSeconds = model.breakTimeInterval
                    self.substate = .interrupt
                    model.delegate?.didStartBreak(remaningSeconds: self.remaningSeconds)
                } else {
                    self.remaningSeconds = model.restTimeInterval
                    self.substate = .rest
                    model.delegate?.didStartWork(partOfCompeletedCycle: self.passedCycles, remaningSeconds: self.remaningSeconds)

                    model.delegate?.didStartRest(remaningSeconds: self.remaningSeconds)
                }
            case .interrupt:
                self.remaningSeconds = model.workTimeInterval
                self.substate = .working
                model.delegate?.didStartWork(partOfCompeletedCycle: self.passedCycles, remaningSeconds: self.remaningSeconds)
            case .rest:
                self.remaningSeconds = model.workTimeInterval
                self.remaningCycles = model.numberOfCycles
                self.substate = .working
                model.delegate?.didStartWork(partOfCompeletedCycle: self.passedCycles, remaningSeconds: self.remaningSeconds)
            }
        }
    }
}

// MARK: - StateSuspended

private extension PomodoroModel {
    
    class StateSuspended: BaseState {
        
        let activeState: StateActive
        
        init(activeState: StateActive) {
            self.activeState = activeState
        }
        
        override func didEnter() {
            self.activeState.timer.suspend()
            self.model?.delegate?.didSuspendWork()
        }
        
        override func stop() {
            self.activeState.stop()
        }
        
        override func resume() {
            guard let model = self.model else { return }
            model.state = self.activeState
            model.delegate?.didResumeWork()
            self.activeState.timer.resume()
        }
    }
}
