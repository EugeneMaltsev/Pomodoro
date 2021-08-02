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
    
    var modelContinuedWork: XCTestExpectation?
    var modelContinuedRest: XCTestExpectation?
    var modelContinuedBreak: XCTestExpectation?
    var modeldidStartedBreak: XCTestExpectation?
    var modeldidStartedRest: XCTestExpectation?
    
    var modelContinuedWorkHandler: ((UInt) -> Void)?
    var modelContinuedRestHandler: ((UInt) -> Void)?

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
    
    func testStartStop() {
        let model = PomodoroModel(workTimeInterval: 10, breakTimeInterval: 2, restTimeInterval: 4, numberOfCycles: 2)
        model.delegate = self
        self.modelStarted = self.expectation(description: "model started")
        self.modelStarted?.expectedFulfillmentCount = 1
        self.modelStopped = self.expectation(description: "model stopped")
        self.modelStopped?.expectedFulfillmentCount = 1
        self.modelSuspended = self.expectation(description: "model suspended")
        self.modelSuspended?.isInverted = true
        self.modelResumed = self.expectation(description: "model resumed")
        self.modelResumed?.isInverted = true
        model.start()
        Thread.sleep(forTimeInterval: 0.1)
        model.stop()
        self.waitForExpectations(timeout: 0)
    //    self.wait(for expectations: [XCTestExpectation], timeout seconds: TimeInterval)
    }
    
    func testStop() {
        let model = PomodoroModel(workTimeInterval: 10, breakTimeInterval: 2, restTimeInterval: 4, numberOfCycles: 2)
        model.delegate = self
    
        self.modelStarted = self.expectation(description: "model started")
        self.modelStarted?.expectedFulfillmentCount = 1

        model.start()
        self.waitForExpectations(timeout: 0)
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
        self.modelStopped = self.expectation(description: "stopped")
        
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
}

// MARK: - PomodoroModelDelegate

extension PomodoroModelTests: PomodoroModelDelegate {
    
    func didStartWork(partOfCompeletedCycle: UInt, remaningSeconds: UInt) {
        self.modelStarted?.fulfill()
    }
    
    func continueWork(remaningSeconds: UInt) {
        self.modelContinuedWork?.fulfill()
        modelContinuedWorkHandler?(remaningSeconds)
    }
    
    func didStartBreak(remaningSeconds: UInt) {
        self.modeldidStartedBreak?.fulfill()
    }
    
    func continueBreak(remaningSeconds: UInt) {
        self.modelContinuedBreak?.fulfill()
    }
    
    func didStartRest(remaningSeconds: UInt) {
        self.modeldidStartedRest?.fulfill()
    }
    
    func continueRest(remaningSeconds: UInt) {
        self.modelContinuedRest?.fulfill()
        modelContinuedRestHandler?(remaningSeconds)
    }
    
    func didSuspendWork() {
        self.modelSuspended?.fulfill()
    }
    
    func didResumeWork() {
        self.modelResumed?.fulfill()
    }
    
    func didStopWork() {
        self.modelStopped?.fulfill()
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
