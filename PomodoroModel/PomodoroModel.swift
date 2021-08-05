//
//  Timer.swift
//  Pomodoro
//
//  Created by Eugene Maltsev on 17.03.2021.
//

import Foundation

public protocol PomodoroModelDelegate: AnyObject {
    func didStartWork(remainingSeconds: UInt)
    func didStartBreak(remainingSeconds: UInt)
    func didStartRest(remainingSeconds: UInt)
    func didStartCycle(partOfCompeletedCycle: UInt)
    func continueWork(remainingSeconds: UInt)
    func continueBreak(remainingSeconds: UInt)
    func continueRest(remainingSeconds: UInt)
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
    public let numberOfCycles: Int
    
    public init(workTimeInterval: TimeInterval = 1500,
                breakTimeInterval: TimeInterval = 300,
                restTimeInterval: TimeInterval = 700,
                numberOfCycles: Int = 4) {
        self.workTimeInterval = workTimeInterval
        self.breakTimeInterval = breakTimeInterval
        self.restTimeInterval = restTimeInterval
        self.numberOfCycles = numberOfCycles // TODO: rename numberOfCycles with any suitable name
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
    
    static var TimerTicksPerSecond = 1
    
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
            let timeInterval = 1.0 / Double(PomodoroModel.TimerTicksPerSecond)
            self.underlyingTimer = UnderlyingTimer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
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
            self.remainingSeconds = model.workTimeInterval
            self.remainingCycles = model.numberOfCycles
            self.timer.fireBlock = { [weak self] in
                self?.timerDidFire()
            }
            self.timer.resume()
            model.delegate?.didStartCycle(partOfCompeletedCycle: self.passedCycles)
            model.delegate?.didStartWork(remainingSeconds: self.remainingSeconds)
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
        private var remainingSeconds = UInt(0)
        private var remainingCycles = Int(0)
        private var passedCycles = UInt(0)
        
        private func timerDidFire() {
            assert(self.remainingSeconds > 0)
            self.remainingSeconds -= 1
            if self.remainingSeconds > 0 {
                self.continueSubstate()
            } else {
                self.switchToNextSubstate()
            }
        }
        
        private func continueSubstate() {
            assert(self.remainingSeconds > 0)
            switch self.substate {
            case .working:
                self.model?.delegate?.continueWork(remainingSeconds: self.remainingSeconds)
            case .interrupt:
                self.model?.delegate?.continueBreak(remainingSeconds: self.remainingSeconds)
            case .rest:
                self.model?.delegate?.continueRest(remainingSeconds: self.remainingSeconds)
            }
        }
        
        private func switchToNextSubstate() {
            assert(self.remainingSeconds == 0)
            guard let model = self.model else { return }
            switch self.substate {
            case .working:
                assert(self.remainingCycles >= 0)
                self.remainingCycles -= 1
                self.passedCycles += 1
                if self.remainingCycles >= 0 {
                    self.remainingSeconds = model.breakTimeInterval
                    self.substate = .interrupt
                    model.delegate?.didStartBreak(remainingSeconds: self.remainingSeconds)
                } else {
                    self.remainingSeconds = model.restTimeInterval
                    self.substate = .rest
                    model.delegate?.didStartCycle(partOfCompeletedCycle: self.passedCycles)
                    model.delegate?.didStartWork(remainingSeconds: self.remainingSeconds)
                    model.delegate?.didStartRest(remainingSeconds: self.remainingSeconds)
                }
            case .interrupt:
                self.remainingSeconds = model.workTimeInterval
                self.substate = .working
                model.delegate?.didStartCycle(partOfCompeletedCycle: self.passedCycles)
                model.delegate?.didStartWork(remainingSeconds: self.remainingSeconds)
            case .rest:
                self.remainingSeconds = model.workTimeInterval
                self.remainingCycles = model.numberOfCycles
                self.substate = .working
                model.delegate?.didStartCycle(partOfCompeletedCycle: self.passedCycles)
                model.delegate?.didStartWork(remainingSeconds: self.remainingSeconds)
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
