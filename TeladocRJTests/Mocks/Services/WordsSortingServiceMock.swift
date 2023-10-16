//
//  WordsSortingServiceMock.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 16.10.2023.
//

import Combine
import Foundation

@testable import TeladocRJ

final class WordsSortingServiceMock: WordsSortingServiceProtocol {
  
  private(set) var invokedSortCount = 0
  private(set) var invokedSortMethod: WordsSortingMethod?
  let stubbedSortResultSubject = PassthroughSubject<[WordFrequenciesItem], Never>()
  
  func sort(items: [WordFrequenciesItem], by method: WordsSortingMethod) -> AnyPublisher<[WordFrequenciesItem], Never> {
    stubbedSortResultSubject
      .handleEvents(receiveSubscription: { _ in
        self.invokedSortCount += 1
        self.invokedSortMethod = method
      })
      .eraseToAnyPublisher()
  }
  
}
