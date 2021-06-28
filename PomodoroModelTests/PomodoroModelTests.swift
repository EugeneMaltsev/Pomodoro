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
}
    
// MARK: - PomodoroModelDelegate

extension PomodoroModelTests: PomodoroModelDelegate {
    
    func didStartWork(partOfCompeletedCycle: UInt, remaningSeconds: UInt) {
        self.modelStarted?.fulfill()
    }
    
    func continueWork(remaningSeconds: UInt) {
        
    }
    
    func didStartBreak(remaningSeconds: UInt) {
        
    }
    
    func continueBreak(remaningSeconds: UInt) {
        
    }
    
    func didStartRest(remaningSeconds: UInt) {
        
    }
    
    func continueRest(remaningSeconds: UInt) {
        
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
