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
  
  // cancellables
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
    // when sorting two items by freqency
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
    XCTAssertEqual(result, expectedItems, "expected items sorted by frequency in descending order")
  }
  
  func test_whenSortingAlphabetically_shouldReturnProperResult() {
    // when sorting two items alphabetically
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
    XCTAssertEqual(result, expectedItems, "expected items sorted alphabetically in ascending order")
  }
  
  func test_whenSortingByLength_shouldReturnProperResult() {
    // when sorting two items by length
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
    XCTAssertEqual(result, expectedItems, "expected items sorted by length in ascending order")
  }
  
}
