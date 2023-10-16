//
//  AsyncWordsSortingService.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 16.10.2023.
//

import Combine
import Foundation

protocol AsyncWordsSortingServiceProtocol {
  func sort(items: [WordFrequenciesItem], by method: WordsSortingMethod) -> AnyPublisher<[WordFrequenciesItem], Never>
}

final class AsyncWordsSortingService: AsyncWordsSortingServiceProtocol {
  
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
