//
//  FileReaderService.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 11.10.2023.
//

import Combine
import Foundation

protocol FileReaderServiceProtocol {
  func readLinesFromFile(fileURL: URL) -> AnyPublisher<String, Never>
}


final class FileReaderService: FileReaderServiceProtocol {
  
  func readLinesFromFile(fileURL: URL) -> AnyPublisher<String, Never> {
    var text: String?
    do {
      text = try String(contentsOf: fileURL, encoding: .ascii)
    } catch {
      print("File error: \(error)")
    }
    return Just(text ?? "").eraseToAnyPublisher()
  }
  
}
