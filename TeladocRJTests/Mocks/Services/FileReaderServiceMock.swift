//
//  FileReaderServiceMock.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import Combine
import Foundation

@testable import TeladocRJ

final class FileReaderServiceMock: FileReaderServiceProtocol {
  
  private(set) var invokedReadLinesFromFileCount = 0
  private(set) var invokedFileURLParameter: URL?
  
  let stubbedReadLinesFromFileResult = PassthroughSubject<String, Error>()
  
  func readLinesFromFile(fileURL: URL) -> AnyPublisher<String, Error> {
    invokedFileURLParameter = fileURL
    return stubbedReadLinesFromFileResult
      .handleEvents(receiveSubscription: { _ in
        self.invokedReadLinesFromFileCount += 1
      })
      .eraseToAnyPublisher()
  }
  
}
