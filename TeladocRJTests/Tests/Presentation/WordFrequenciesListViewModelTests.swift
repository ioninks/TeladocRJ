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
  private var wordsSortingServiceMock: WordsSortingServiceMock!
  
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
  
  // MARK: Tests
  
  func test_whenReceivedSortedWordsFromService_shouldReturnCorrectCellConfigurations() {
    // given
    setUpViewModel(fileURL: Constants.fileURL)
    
    // when
    fileReaderServiceMock.stubbedReadLinesFromFileResult.send(Constants.text)
    
    // then
    XCTAssertEqual(
      wordsCounterServiceMock.invokedCountWordFrequenciesInCount, 1,
      "expected wordsCounterService to be invoked once"
    )
    
    // when
    let counts: [String: Int] = [
      "No": 1,
      "Yes": 2
    ]
    wordsCounterServiceMock.stubbedCountInteractivelyInResult.send(counts)
    
    // when
    let sortedWords: [WordFrequenciesItem] = [
      .init(word: "Yes", count: 2),
      .init(word: "No", count: 1)
    ]
    wordsSortingServiceMock.stubbedSortResultSubject.send(sortedWords)
    
    // then
    let configurationsSortedByWordFrequencies: [WordFrequenciesCellConfiguration] = [
      .init(title: "Yes", value: "2"),
      .init(title: "No", value: "1")
    ]
    XCTAssertEqual(
      cellConfigurationsAccumulator, [configurationsSortedByWordFrequencies],
      "should return configurations for words sorted by frequencies"
    )
  }
  
  func test_whenChosingDifferentSortingMethods_shouldProperlySortWords() {
    // given
    setUpViewModel(fileURL: Constants.fileURL)
    
    // when
    wordsCounterServiceMock.stubbedCountInteractivelyInResult.send(Constants.counts)
    
    // then
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortCount, 1,
      "should sort words once"
    )
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortMethod, .byFrequency,
      "should sort words by frequency"
    )
    
    // when
    didSelectSortControlItemAtIndexSubject.send(1)
    
    // then
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortCount, 2,
      "should sort words the second time"
    )
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortMethod, .alphabetically,
      "should sort words alphabetically"
    )
    
    // when
    didSelectSortControlItemAtIndexSubject.send(1)
    
    // then
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortCount, 3,
      "should sort words the third time"
    )
    XCTAssertEqual(
      wordsSortingServiceMock.invokedSortMethod, .alphabetically,
      "should sort words by length"
    )
  }
  
}

// MARK: - Helper Methods

private extension WordFrequenciesListViewModelTests {
  
  func setUpViewModel(fileURL: URL) {
    fileReaderServiceMock = .init()
    wordsCounterServiceMock = .init()
    wordsSortingServiceMock = .init()
    
    viewModel = .init(
      fileURL: fileURL,
      dependencies: .init(
        fileReaderService: fileReaderServiceMock,
        wordsCounterService: wordsCounterServiceMock,
        wordsSortingService: wordsSortingServiceMock
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
