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

enum WordsSortingMethod: CaseIterable {
  case byFrequency
  case alphabetically
  case byLength
  
  var title: String {
    switch self {
    case .byFrequency: return "By Frequency"
    case .alphabetically: return "Alphabetically"
    case .byLength: return "By Length"
    }
  }
}

struct WordFrequenciesListViewModelInput {
  let didSelectSortControlItemAtIndex: AnyPublisher<Int, Never>
}

struct WordFrequenciesListViewModelOutput {
  let cellConfigurations: AnyPublisher<[WordFrequenciesCellConfiguration], Never>
  let sortControlTitles: AnyPublisher<[String], Never>
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
    
    let selectedSortingMethod = input.didSelectSortControlItemAtIndex
      .map { index in WordsSortingMethod.allCases[index] }
      .prepend(WordsSortingMethod.allCases[0])
    
    let sortedItems = items
      .combineLatest(selectedSortingMethod)
      .map { list, sortingMethod in
        switch sortingMethod {
        case .byFrequency:
          return list.sorted(by: { $0.count > $1.count })
        case .alphabetically:
          return list.sorted(by: { $0.word < $1.word })
        case .byLength:
          return list.sorted(by: { $0.word.count > $1.word.count })
        }
      }
    
    let configurations = sortedItems
      .map { list in
        list.map(\.asCellConfiguration)
      }
    
    let sortControlTitles = WordsSortingMethod.allCases
      .map(\.title)
    
    return .init(
      cellConfigurations: configurations.eraseToAnyPublisher(),
      sortControlTitles: Just(sortControlTitles).eraseToAnyPublisher()
    )
  }
  
}

private extension WordFrequenciesItem {
  
  var asCellConfiguration: WordFrequenciesCellConfiguration {
    .init(title: self.word, value: "\(self.count)")
  }
  
}
