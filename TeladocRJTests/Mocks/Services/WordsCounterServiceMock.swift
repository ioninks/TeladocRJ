//
//  WordsCounterServiceMock.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import Combine
import Foundation

@testable import TeladocRJ

final class WordsCounterServiceMock: WordsCounterServiceProtocol {
  
  private(set) var invokedCountWordFrequenciesInCount = 0
  
  let stubbedCountInteractivelyInResult = PassthroughSubject<[String: Int], Never>()
  
  func countWordFrequenciesIn(lines: AnyPublisher<String, Never>) -> AnyPublisher<[String: Int], Never> {
    return stubbedCountInteractivelyInResult
      .handleEvents(receiveSubscription: { _ in
        self.invokedCountWordFrequenciesInCount += 1
      })
      .eraseToAnyPublisher()
  }
  
}
