//
//  PomodoroModelTests.swift
//  PomodoroModelTests
//
//  Created by Eugene Maltsev on 26.06.2021.
//

import XCTest
import PomodoroModel

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
    
    var modelContinuedRestHandler: ((UInt) -> Void)?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        let model = PomodoroModel(workTimeInterval: 2, breakTimeInterval: 2, restTimeInterval: 2, numberOfCycles: 1)
        model.delegate = self
        
        self.modelContinuedWork = self.expectation(description: "continueWork")
        self.modelContinuedWork?.expectedFulfillmentCount = 2
        self.modeldidStartedBreak = self.expectation(description: "didStartBreak")
        self.modeldidStartedBreak?.expectedFulfillmentCount = 1
        self.modelContinuedBreak = self.expectation(description: "continueBreak")
        self.modelContinuedBreak?.expectedFulfillmentCount = 1
        self.modeldidStartedRest = self.expectation(description: "didStartRest")
        self.modeldidStartedRest?.expectedFulfillmentCount = 1
        self.modelContinuedRest = self.expectation(description: "continueRest")
        self.modelContinuedRest?.expectedFulfillmentCount = 1
        self.modelContinuedRestHandler? = { (remainingSeconds: UInt) in
            if remainingSeconds == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                    model.stop()
                }
            }
        }
        model.start()
        waitForExpectations(timeout: 10)
    }
}

// MARK: - PomodoroModelDelegate

extension PomodoroModelTests: PomodoroModelDelegate {
    
    func didStartWork(partOfCompeletedCycle: UInt, remaningSeconds: UInt) {
        self.modelStarted?.fulfill()
    }
    
    func continueWork(remaningSeconds: UInt) {
        self.modelContinuedWork?.fulfill()
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
