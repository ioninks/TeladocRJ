//
//  WordFrequenciesListViewModelTests.swift
//  TeladocRJTests
//
//  Created by Konstantin Ionin on 12.10.2023.
//

import Combine
import XCTest

@testable import TeladocRJ

private enum Constants {
  static let fileURL = URL(string: "/some/url")!
  static let text = "Two households, both alike in dignity"
  static let counts: [String: Int] = [
    "No": 1,
    "Yes": 2
  ]
}

final class WordFrequenciesListViewModelTests: XCTestCase {
  
  // system under test
  private var viewModel: WordFrequenciesListViewModel!
  
  // mocks
  private var fileReaderServiceMock: FileReaderServiceMock!
  private var wordsCounterServiceMock: WordsCounterServiceMock!
  
  // cancellables
  private var cellConfigurationsCancellable: AnyCancellable!
  
  // input subjects
  private var didSelectSortControlItemAtIndexSubject: PassthroughSubject<Int, Never>!
  
  // output accumulators
  private var cellConfigurationsAccumulator: [[WordFrequenciesCellConfiguration]]!
    
  override func tearDown() {
    viewModel = nil
    fileReaderServiceMock = nil
    wordsCounterServiceMock = nil
    cellConfigurationsCancellable = nil
    didSelectSortControlItemAtIndexSubject = nil
    cellConfigurationsAccumulator = nil
    
    super.tearDown()
  }
  
  func test_whenReceivedCountsFromTheService_shouldReturnCorrectCellConfigurations() {
    // given
    setUpViewModel(fileURL: Constants.fileURL)
    
    // when
    fileReaderServiceMock.stubbedReadLinesFromFileResult.send(Constants.text)
    
    // then
    XCTAssertEqual(
      wordsCounterServiceMock.invokedCountInteractivelyInCount, 1,
      "expected wordsCounterService to be invoked once"
    )
    
    // when
    let counts: [String: Int] = [
      "No": 1,
      "Yes": 2
    ]
    wordsCounterServiceMock.stubbedCountInteractivelyInResult.send(counts)
    wordsCounterServiceMock.stubbedCountInteractivelyInResult.send(completion: .finished)
    
    // then
    let configurationsSortedByWordFrequencies: [WordFrequenciesCellConfiguration] = [
      .init(title: "Yes", value: "2"),
      .init(title: "No", value: "1")
    ]
    XCTAssertEqual(
      cellConfigurationsAccumulator, [configurationsSortedByWordFrequencies],
      "should return configurations for words sorted by frequencies"
    )
    
    // when
    didSelectSortControlItemAtIndexSubject.send(1)
    
    // then
    let configurationsSortedByWordsAlphabetically: [WordFrequenciesCellConfiguration] = [
      .init(title: "No", value: "1"),
      .init(title: "Yes", value: "2")
    ]
    XCTAssertEqual(
      cellConfigurationsAccumulator.last, configurationsSortedByWordsAlphabetically,
      "should return configurations for words sorted alphabetically"
    )
    
    // when
    didSelectSortControlItemAtIndexSubject.send(2)
    
    // then
    let configurationsSortedByWordLength: [WordFrequenciesCellConfiguration] = [
      .init(title: "Yes", value: "2"),
      .init(title: "No", value: "1")
    ]
    XCTAssertEqual(
      cellConfigurationsAccumulator.last, configurationsSortedByWordLength,
      "should return configurations for words sorted by length"
    )
  }
  
}

private extension WordFrequenciesListViewModelTests {
  
  func setUpViewModel(fileURL: URL) {
    fileReaderServiceMock = .init()
    wordsCounterServiceMock = .init()
    
    viewModel = .init(
      fileURL: fileURL,
      dependencies: .init(
        fileReaderService: fileReaderServiceMock,
        wordsCounterService: wordsCounterServiceMock
      )
    )
    
    didSelectSortControlItemAtIndexSubject = .init()
    cellConfigurationsAccumulator = []
    
    let output = viewModel.bind(
      input: .init(
        didSelectSortControlItemAtIndex: didSelectSortControlItemAtIndexSubject.eraseToAnyPublisher()
      )
    )
    
    cellConfigurationsCancellable = output.cellConfigurations
      .sink(receiveValue: { configurations in
        self.cellConfigurationsAccumulator.append(configurations)
      })
  }
  
}
