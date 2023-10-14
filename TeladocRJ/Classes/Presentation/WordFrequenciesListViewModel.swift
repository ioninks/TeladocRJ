//
//  WordFrequenciesListViewModel.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 11.10.2023.
//

import Combine
import Foundation

struct WordFrequenciesCellConfiguration: Hashable {
  let title: String
  let value: String
}

private struct WordFrequenciesItem {
  let word: String
  let count: Int
}

struct WordFrequenciesListViewModelInput {
  
}

struct WordFrequenciesListViewModelOutput {
  let cellConfigurations: AnyPublisher<[WordFrequenciesCellConfiguration], Never>
}

protocol WordFrequenciesListViewModelProtocol {
  func bind(input: WordFrequenciesListViewModelInput) -> WordFrequenciesListViewModelOutput
}

final class WordFrequenciesListViewModel: WordFrequenciesListViewModelProtocol {
  
  struct Dependencies {
    let fileReaderService: FileReaderServiceProtocol
    let wordsCounterService: WordsCounterServiceProtocol
  }
  
  private let fileURL: URL
  private let dependencies: Dependencies
  
  init(fileURL: URL, dependencies: Dependencies) {
    self.fileURL = fileURL
    self.dependencies = dependencies
  }
  
  // MARK: WordFrequenciesListViewModelProtocol
  
  func bind(input: WordFrequenciesListViewModelInput) -> WordFrequenciesListViewModelOutput {
    let lines: AnyPublisher<String, Never> = dependencies.fileReaderService.readLinesFromFile(fileURL: fileURL)
      .replaceError(with: "")
      .eraseToAnyPublisher()
    
    let countsDictionary = dependencies.wordsCounterService.countInteractivelyIn(lines: lines)
      .last()
    
    let items = countsDictionary
      .map { dictionary in
        dictionary.map { word, count in
          WordFrequenciesItem(word: word, count: count)
        }
      }
    
    let sortedItems = items
      .map { list in
        list.sorted(by: { $0.count > $1.count })
      }
    
    let configurations = sortedItems
      .map { list in
        list.map(\.asCellConfiguration)
      }
    
    return .init(cellConfigurations: configurations.eraseToAnyPublisher())
  }
  
}

private extension WordFrequenciesItem {
  
  var asCellConfiguration: WordFrequenciesCellConfiguration {
    .init(title: self.word, value: "\(self.count)")
  }
  
}
