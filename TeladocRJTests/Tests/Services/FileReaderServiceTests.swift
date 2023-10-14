//
//  FileReaderServiceTests.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import XCTest

@testable import TeladocRJ

final class FileReaderServiceTests: XCTestCase {
  
  private var service: FileReaderService!
  
  override func setUp() {
    super.setUp()
    
    service = .init()
  }
  
  override func tearDown() {
    service = nil
    
    super.tearDown()
  }
  
  func test_whenGivenInvalidURL_returnsError() {
    // given
    let fileURL = URL(string: "/none")!
    
    // when
    var result: String?
    var error: Error?
    _ = service.readLinesFromFile(fileURL: fileURL)
      .sink { completion in
        if case .failure(let completionError) = completion {
          error = completionError
        }
      } receiveValue: { value in
        result = value
      }
    
    XCTAssertNil(result, "result should be nil")
    XCTAssertNotNil(error, "error should NOT be nil")

  }
  
}
