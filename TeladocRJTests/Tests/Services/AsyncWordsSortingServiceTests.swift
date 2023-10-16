//
//  WordsSortingServiceTests.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 16.10.2023.
//

import Combine
import XCTest

@testable import TeladocRJ

final class WordsSortingServiceTests: XCTestCase {
  
  // system under test
  private var service: WordsSortingService!
  
  private var resultCancellable: AnyCancellable!
  
  override func setUp() {
    super.setUp()
    
    service = .init()
  }
  
  override func tearDown() {
    service = nil
    resultCancellable = nil
    
    super.tearDown()
  }
  
  // MARK: Tests
  
  func test_whenSortingByFreqency_shouldReturnProperResult() {
    // when
    let items: [WordFrequenciesItem] = [
      .init(word: "No", count: 1),
      .init(word: "Yes", count: 2)
    ]
    let expectation = XCTestExpectation()
    var result: [WordFrequenciesItem] = []
    resultCancellable = service.sort(items: items, by: .byFrequency)
      .sink(receiveValue: { sortedItems in
        expectation.fulfill()
        result = sortedItems
      })
    
    // then
    let expectedItems: [WordFrequenciesItem] = [
      .init(word: "Yes", count: 2),
      .init(word: "No", count: 1)
    ]
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(result, expectedItems)
  }
  
  func test_whenSortingAlphabetically_shouldReturnProperResult() {
    // when
    let items: [WordFrequenciesItem] = [
      .init(word: "Yes", count: 2),
      .init(word: "No", count: 1)
    ]
    let expectation = XCTestExpectation()
    var result: [WordFrequenciesItem] = []
    resultCancellable = service.sort(items: items, by: .alphabetically)
      .sink(receiveValue: { sortedItems in
        expectation.fulfill()
        result = sortedItems
      })
    
    // then
    let expectedItems: [WordFrequenciesItem] = [
      .init(word: "No", count: 1),
      .init(word: "Yes", count: 2)
    ]
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(result, expectedItems)
  }
  
  func test_whenSortingByLength_shouldReturnProperResult() {
    // when
    let items: [WordFrequenciesItem] = [
      .init(word: "Yes", count: 2),
      .init(word: "No", count: 1),
    ]
    let expectation = XCTestExpectation()
    var result: [WordFrequenciesItem] = []
    resultCancellable = service.sort(items: items, by: .byLength)
      .sink(receiveValue: { sortedItems in
        expectation.fulfill()
        result = sortedItems
      })
    
    // then
    let expectedItems: [WordFrequenciesItem] = [
      .init(word: "No", count: 1),
      .init(word: "Yes", count: 2)
    ]
    wait(for: [expectation], timeout: 1.0)
    XCTAssertEqual(result, expectedItems)
  }
  
}
