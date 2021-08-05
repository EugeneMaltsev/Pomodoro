//
//  PomodoroModelTests.swift
//  PomodoroModelTests
//
//  Created by Eugene Maltsev on 26.06.2021.
//

import XCTest
@testable import PomodoroModel

class PomodoroModelTests: XCTestCase {
    
    var modelStarted: XCTestExpectation?
    var modelStopped: XCTestExpectation?
    var modelSuspended: XCTestExpectation?
    var modelResumed: XCTestExpectation?
    
    var modeldidStartedBreak: XCTestExpectation?
    var modeldidStartedRest: XCTestExpectation?
    var modeldidStartedCycle: XCTestExpectation?
    var modelContinuedWork: XCTestExpectation?
    var modelContinuedRest: XCTestExpectation?
    var modelContinuedBreak: XCTestExpectation?
    
    var modelContinuedWorkHandler: ((UInt) -> Void)?
    var modelContinuedBreakHandler: ((UInt) -> Void)?
    var modelContinuedRestHandler: ((UInt) -> Void)?
    
    var modelDidStartWorkHandler: ((UInt) -> Void)?
    var modelDidStartBreakHandler: ((UInt) -> Void)?
    var modelDidStartRestHandler: ((UInt) -> Void)?
    var modelDidStartCycleHandler: ((UInt) -> Void)?
    
    var modelSuspendHandler: (() -> Void)?
    var modelResumeHandler: (() -> Void)?
    var modelStopHandler: (() -> Void)?
    
    override func setUpWithError() throws {
        PomodoroModel.TimerTicksPerSecond = 1000
    }
    
    override func tearDownWithError() throws {
        PomodoroModel.TimerTicksPerSecond = 1
    }
    
    func testDefaultCreation() throws {
        let model = PomodoroModel()
        XCTAssertEqual(model.workTimeInterval, 1500)
        XCTAssertEqual(model.restTimeInterval, 700)
        XCTAssertEqual(model.breakTimeInterval, 300)
        XCTAssertEqual(model.numberOfCycles, 4)
    }
    
    func testParametrizedCreation() throws {
        let model = PomodoroModel(workTimeInterval: 1000, breakTimeInterval: 200, restTimeInterval: 500, numberOfCycles: 2)
        XCTAssertEqual(model.workTimeInterval, 1000)
        XCTAssertEqual(model.restTimeInterval, 500)
        XCTAssertEqual(model.breakTimeInterval, 200)
        XCTAssertEqual(model.numberOfCycles, 2)
    }
    
    func testCompleteWay() {
        let model = PomodoroModel(workTimeInterval: 200, breakTimeInterval: 50, restTimeInterval: 20, numberOfCycles: 2)
        model.delegate = self
        
        self.modelStarted = self.expectation(description: "model started")
        self.modelContinuedWork = self.expectation(description: "continueWork")
        self.modeldidStartedBreak = self.expectation(description: "didStartBreak")
        self.modelContinuedBreak = self.expectation(description: "continueBreak")
        self.modeldidStartedRest = self.expectation(description: "didStartRest")
        self.modelContinuedRest = self.expectation(description: "continueRest")
        self.modelStopped = self.expectation(description: "model stopped")
        
        self.modelStarted?.expectedFulfillmentCount = Int(modelStartedExpectedFulfillmentCount(cycles: UInt(model.numberOfCycles)))
        self.modelContinuedWork?.expectedFulfillmentCount = Int(workExpectedFulfillmentCount(work: model.workTimeInterval, cycles: UInt(model.numberOfCycles)))
        self.modeldidStartedBreak?.expectedFulfillmentCount = Int(breakCyclesEpcectedFulfillmentCount(cycles: UInt(model.numberOfCycles)))
        self.modelContinuedBreak?.expectedFulfillmentCount = Int(breakExpectedFulfillmentCount(brake: model.breakTimeInterval, cycles: UInt(model.numberOfCycles)))
        self.modeldidStartedRest?.expectedFulfillmentCount = Int(restCyclesEpcectedFulfillmentCount(cycles: UInt(model.numberOfCycles)))
        self.modelContinuedRest?.expectedFulfillmentCount = Int(restExpectedFulfillmentCount(rest: model.restTimeInterval, cycles: UInt(model.numberOfCycles)))
        
        self.modelContinuedRestHandler = { (remainingSeconds: UInt) in
            if remainingSeconds == 1 {
                DispatchQueue.main.async{
                    model.stop()
                }
            }
        }
        model.start()
        waitForExpectations(timeout: 1)
    }
    
    func testStartStop() {
        let model = PomodoroModel(workTimeInterval: 10, breakTimeInterval: 2, restTimeInterval: 4, numberOfCycles: 2)
        model.delegate = self
        
        self.modelStopped = self.expectation(description: "model stopped")
        self.modelStopped?.expectedFulfillmentCount = 1
        
        self.modelDidStartWorkHandler = { _ in
            DispatchQueue.main.async{
                model.stop()
            }
        }
        model.start()
        self.waitForExpectations(timeout: 0.1)
    }
    
    func testStartSuspendStop() {
        let model = PomodoroModel(workTimeInterval: 200, breakTimeInterval: 50, restTimeInterval: 20, numberOfCycles: 1)
        model.delegate = self
        
        self.modelSuspended = self.expectation(description: "model suspended")
        self.modelSuspended?.expectedFulfillmentCount = 1
        
        self.modelSuspendHandler = {
            DispatchQueue.main.async{
                model.stop()
            }
        }
        model.start()
        model.suspend()
        waitForExpectations(timeout: 1)
    }
    
    func testStartSuspendResume() {
        let model = PomodoroModel(workTimeInterval: 10, breakTimeInterval: 2, restTimeInterval: 4, numberOfCycles: 2)
        model.delegate = self
        
        self.modelSuspended = self.expectation(description: "model suspended")
        self.modelResumed = self.expectation(description: "model resumed")
        self.modelSuspended?.expectedFulfillmentCount = 1
        self.modelResumed?.expectedFulfillmentCount = 1
        
        self.modelResumeHandler = {
            DispatchQueue.main.async{
                model.stop()
            }
        }
        model.start()
        model.suspend()
        model.resume()
        waitForExpectations(timeout: 0.1)
    }
}

// MARK: - PomodoroModelDelegate

extension PomodoroModelTests: PomodoroModelDelegate {
    
    func didStartWork(remainingSeconds: UInt) {
        self.modelStarted?.fulfill()
        modelDidStartWorkHandler?(remainingSeconds)
    }
    
    func didStartBreak(remainingSeconds: UInt) {
        self.modeldidStartedBreak?.fulfill()
        modelDidStartBreakHandler?(remainingSeconds)
    }
    
    func didStartRest(remainingSeconds: UInt) {
        self.modeldidStartedRest?.fulfill()
        modelDidStartRestHandler?(remainingSeconds)
    }
    
    func didStartCycle(partOfCompeletedCycle: UInt) {
        self.modeldidStartedCycle?.fulfill()
        modelDidStartCycleHandler?(partOfCompeletedCycle)
    }
    
    func continueWork(remainingSeconds: UInt) {
        self.modelContinuedWork?.fulfill()
        modelContinuedWorkHandler?(remainingSeconds)
    }
    
    func continueBreak(remainingSeconds: UInt) {
        self.modelContinuedBreak?.fulfill()
        modelContinuedBreakHandler?(remainingSeconds)
    }
    
    func continueRest(remainingSeconds: UInt) {
        self.modelContinuedRest?.fulfill()
        modelContinuedRestHandler?(remainingSeconds)
    }
    
    func didSuspendWork() {
        self.modelSuspended?.fulfill()
        modelSuspendHandler?()
    }
    
    func didResumeWork() {
        self.modelResumed?.fulfill()
        modelResumeHandler?()
    }
    
    func didStopWork() {
        self.modelStopped?.fulfill()
        modelStopHandler?()
    }
}

func workExpectedFulfillmentCount(work: UInt, cycles: UInt) -> UInt {
    let c = cycles + 1
    let b = c * work - c
    return b
}

func breakExpectedFulfillmentCount(brake: UInt, cycles: UInt) -> UInt {
    let a = cycles * brake - cycles
    return a
}

func restExpectedFulfillmentCount(rest: UInt, cycles: UInt) -> UInt {
    return rest - 1
}

func breakCyclesEpcectedFulfillmentCount(cycles: UInt) -> UInt {
    return cycles
}

func restCyclesEpcectedFulfillmentCount(cycles: UInt) -> UInt {
    return 1
}

func modelStartedExpectedFulfillmentCount(cycles: UInt) -> UInt {
    if cycles == 1 {
        return 3
    } else {
        return cycles + 2
    }
}
