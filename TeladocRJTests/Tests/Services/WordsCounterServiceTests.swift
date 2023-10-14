//
//  WordsCounterServiceTests.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import Combine
import XCTest

@testable import TeladocRJ

final class WordsCounterServiceTests: XCTestCase {
  
  private var service: WordsCounterService!
  
  override func setUp() {
    super.setUp()
    
    service = .init()
  }
  
  override func tearDown() {
    service = nil
    
    super.tearDown()
  }
  
  func test_whenGivenTextWithMultipleLines_producesCorrectResult() {
    // given
    let text = """
    Do you quarrel, sir?
    Quarrel, sir? No, sir.
    """
    
    // when
    var result: [String: Int] = [:]
    _ = service.countInteractivelyIn(lines: Just(text).eraseToAnyPublisher())
      .sink(receiveValue: { result = $0 })
    
    // then
    let expectedResult: [String: Int] = [
      "Do": 1,
      "You": 1,
      "Quarrel": 2,
      "Sir": 3,
      "No": 1
    ]
    XCTAssertEqual(result, expectedResult)
  }
  
  func test_whenEmittingTwoLinesSeparately_producesCorrectFinalResult() {
    // given
    let line1 = "Do you quarrel, sir?"
    let line2 = "Quarrel, sir? No, sir."
    
    var result: [String: Int] = [:]
    _ = service.countInteractivelyIn(lines: Just(line1).append(line2).eraseToAnyPublisher())
      .sink(receiveValue: { result = $0 })
    
    // then
    let expectedResult: [String: Int] = [
      "Do": 1,
      "You": 1,
      "Quarrel": 2,
      "Sir": 3,
      "No": 1
    ]
    XCTAssertEqual(result, expectedResult, "expected correct result after sending the second line")
  }
  
}
