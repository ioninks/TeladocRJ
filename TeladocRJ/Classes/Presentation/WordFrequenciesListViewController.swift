//
//  WordFrequenciesListViewController.swift
//  TeladocRJ
//
//  Created by Konstantin Ionin on 10.10.2023.
//

import Combine
import UIKit

private enum Constants {
  static let cellIdentifier = "WordFrequenciesCell"
  static let mediumSpacing: CGFloat = 16
  static let smallSpacing: CGFloat = 12
  static let cornerRadius: CGFloat = 16
}

class WordFrequenciesListViewController: UIViewController {
  
  // MARK: UI
  
  private let tableView = UITableView()
  private let controlsContainer = UIView()
  private let sortControlLabel = UILabel()
  private let sortSelector = UISegmentedControl()
  
  // MARK: Private Properties
  
  private var tableViewDataSource: UITableViewDiffableDataSource<Int, WordFrequenciesCellConfiguration>?
  
  private let viewModel: WordFrequenciesListViewModelProtocol
  
  private let didSelectSortControlItemAtIndexSubject = PassthroughSubject<Int, Never>()
  
  private var disposeBag = Set<AnyCancellable>()
  
  // MARK: Init
  
  init(viewModel: WordFrequenciesListViewModelProtocol) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setHierarchy()
    setUI()
    setLayout()
    setDataSource()
    setBindings()
  }
  
}

// MARK: - Data Source

private extension WordFrequenciesListViewController {
  
  func setDataSource() {
    tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, _, configuration in
      let cell: UITableViewCell
      if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) {
        cell = dequeuedCell
      } else {
        cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.cellIdentifier)
      }
      
      var content = cell.defaultContentConfiguration()
      content.text = configuration.title
      content.secondaryText = configuration.value
      
      cell.contentConfiguration = content
      cell.backgroundColor = .secondarySystemBackground
      return cell
    })
  }
  
}

// MARK: - Bindings

private extension WordFrequenciesListViewController {
  
  func setBindings() {
    let output = viewModel.bind(
      input: .init(
        didSelectSortControlItemAtIndex: didSelectSortControlItemAtIndexSubject.eraseToAnyPublisher()
      )
    )
    
    output.cellConfigurations
      .receive(on: DispatchQueue.main)
      .sink { [tableViewDataSource] configurations in
        var snapshot = NSDiffableDataSourceSnapshot<Int, WordFrequenciesCellConfiguration>()
        snapshot.appendSections([0])
        snapshot.appendItems(configurations)
        tableViewDataSource?.apply(snapshot)
      }
      .store(in: &disposeBag)
    
    output.sortControlTitles
      .receive(on: DispatchQueue.main)
      .sink { [sortSelector, didSelectSortControlItemAtIndexSubject] titles in
        sortSelector.removeAllSegments()
        for (index, title) in titles.enumerated().reversed() {
          let action = UIAction(
            title: title,
            handler: { _ in
              didSelectSortControlItemAtIndexSubject.send(index)
            }
          )
          sortSelector.insertSegment(action: action, at: 0, animated: false)
        }
        sortSelector.selectedSegmentIndex = 0
      }
      .store(in: &disposeBag)
  }
  
}

// MARK: Views Setup

private extension WordFrequenciesListViewController {
  
  func setHierarchy() {
    view.addSubview(tableView)
    view.addSubview(controlsContainer)
    
    controlsContainer.addSubview(sortControlLabel)
    controlsContainer.addSubview(sortSelector)
  }
  
  func setUI() {
    view.backgroundColor = .secondarySystemBackground
    
    tableView.backgroundColor = .secondarySystemBackground
    tableView.allowsSelection = false
    
    controlsContainer.backgroundColor = .systemBackground
    controlsContainer.layer.cornerRadius = Constants.cornerRadius
    controlsContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    
    sortControlLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    sortControlLabel.text = "Sorting"
  }
  
  func setLayout() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    
    controlsContainer.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      controlsContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
      controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      controlsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    sortControlLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      sortControlLabel.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: Constants.mediumSpacing),
      sortControlLabel.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: Constants.mediumSpacing),
      sortControlLabel.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -Constants.mediumSpacing)
    ])
    
    sortSelector.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      sortSelector.topAnchor.constraint(equalTo: sortControlLabel.bottomAnchor, constant: Constants.smallSpacing),
      sortSelector.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: Constants.mediumSpacing),
      sortSelector.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -Constants.mediumSpacing),
      sortSelector.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.mediumSpacing)
    ])
    
    
  }
  
}
