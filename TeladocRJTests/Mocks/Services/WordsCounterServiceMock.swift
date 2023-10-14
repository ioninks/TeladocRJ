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
  
  private(set) var invokedCountInteractivelyInCount = 0
  
  let stubbedCountInteractivelyInResult = PassthroughSubject<[String: Int], Never>()
  
  func countInteractivelyIn(lines: AnyPublisher<String, Never>) -> AnyPublisher<[String: Int], Never> {
    return stubbedCountInteractivelyInResult
      .handleEvents(receiveSubscription: { _ in
        self.invokedCountInteractivelyInCount += 1
      })
      .eraseToAnyPublisher()
  }
  
}
