//
//  WordsCounterService.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 11.10.2023.
//

import Combine
import Foundation

protocol WordsCounterServiceProtocol {
  func countInteractivelyIn(lines: AnyPublisher<String, Never>) -> AnyPublisher<[String: Int], Never>
}

final class WordsCounterService: WordsCounterServiceProtocol {

  func countInteractivelyIn(lines: AnyPublisher<String, Never>) -> AnyPublisher<[String: Int], Never> {
    let result = lines.reduce([String: Int]()) { partialResult, line in
      let lineResult = Self.countWordsIn(line: line)
      return partialResult.merging(lineResult, uniquingKeysWith: +)
    }
    
    return result.eraseToAnyPublisher()
  }
  
  private static func countWordsIn(line: String) -> [String: Int] {
    let separators: CharacterSet = .whitespacesAndNewlines
      .union(.punctuationCharacters)
    
    let words = line.components(separatedBy: separators)
      .filter { $0.isEmpty == false }
      .map(\.capitalized)
    
    var counts: [String: Int] = [:]
    for word in words {
      if counts[word] == nil {
        counts[word] = 0
      }
      counts[word]! += 1
    }
    
    return counts
  }

}
