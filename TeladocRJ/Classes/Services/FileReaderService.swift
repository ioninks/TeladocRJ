//
//  FileReaderService.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 11.10.2023.
//

import Combine
import Foundation

protocol FileReaderServiceProtocol {
  /// Read the file using `ascii` encoding on a background thread and return all the content as one `String` using a publisher
  func readLinesFromFile(fileURL: URL) -> AnyPublisher<String, Error>
}


final class FileReaderService: FileReaderServiceProtocol {
  
  func readLinesFromFile(fileURL: URL) -> AnyPublisher<String, Error> {
    return Deferred {
      Future { promise in
        Task {
          do {
            let text = try String(contentsOf: fileURL, encoding: .ascii)
            promise(.success(text))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
}
