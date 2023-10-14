//
//  FileReaderServiceTests.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import Combine
import XCTest

@testable import TeladocRJ

final class FileReaderServiceTests: XCTestCase {
  
  private var service: FileReaderService!
  
  private var readLinesCancellable: AnyCancellable!
  
  override func setUp() {
    super.setUp()
    
    service = .init()
  }
  
  override func tearDown() {
    service = nil
    readLinesCancellable = nil
    
    super.tearDown()
  }
  
  func test_whenGivenInvalidURL_returnsError() {
    // given
    let fileURL = URL(string: "/none")!
    let expectation = XCTestExpectation()
    
    // when
    var result: String?
    var error: Error?
    readLinesCancellable = service.readLinesFromFile(fileURL: fileURL)
      .sink { completion in
        if case .failure(let completionError) = completion {
          error = completionError
        }
        expectation.fulfill()
      } receiveValue: { value in
        result = value
        expectation.fulfill()
      }
    wait(for: [expectation], timeout: 1.0)
    
    // then
    XCTAssertNil(result, "result should be nil")
    XCTAssertNotNil(error, "error should NOT be nil")

  }
  
}
