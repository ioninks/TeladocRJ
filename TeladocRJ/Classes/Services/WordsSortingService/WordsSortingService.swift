//
//  WordsSortingService.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 16.10.2023.
//

import Combine
import Foundation

protocol WordsSortingServiceProtocol {
  /// Sort items using provided method on a background thread and return the result using a publisher
  func sort(items: [WordFrequenciesItem], by method: WordsSortingMethod) -> AnyPublisher<[WordFrequenciesItem], Never>
}

final class WordsSortingService: WordsSortingServiceProtocol {
  
  func sort(items: [WordFrequenciesItem], by method: WordsSortingMethod) -> AnyPublisher<[WordFrequenciesItem], Never> {
    return Deferred {
      Future { promise in
        Task {
          let sorted: [WordFrequenciesItem]
          switch method {
          case .byFrequency:
            sorted = items.sorted(by: { $0.count > $1.count })
          case .alphabetically:
            sorted = items.sorted(by: { $0.word < $1.word })
          case .byLength:
            sorted = items.sorted(by: { $0.word.count < $1.word.count })
          }
          promise(.success(sorted))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
}
