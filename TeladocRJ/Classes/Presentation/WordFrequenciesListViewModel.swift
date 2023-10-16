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
    let wordsSortingService: AsyncWordsSortingServiceProtocol
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
    
    let countsDictionary = dependencies.wordsCounterService.countWordFrequenciesIn(lines: lines)
    
    let items = countsDictionary
      .map { dictionary in
        dictionary.map { word, count in
          WordFrequenciesItem(word: word, count: count)
        }
      }
    
    let selectedSortingMethod = input.didSelectSortControlItemAtIndex
      .map { index in WordsSortingMethod.allCases[index] }
      // initially sort by frequency
      .prepend(WordsSortingMethod.allCases[0])
    
    let sortedItems = items
      .combineLatest(selectedSortingMethod)
      .map { [dependencies] list, sortingMethod in
        dependencies.wordsSortingService.sort(items: list, by: sortingMethod)
      }
      .switchToLatest()
    
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

private extension WordsSortingMethod {
  
  var title: String {
    switch self {
    case .byFrequency: return "By Frequency"
    case .alphabetically: return "Alphabetically"
    case .byLength: return "By Length"
    }
  }
  
}
