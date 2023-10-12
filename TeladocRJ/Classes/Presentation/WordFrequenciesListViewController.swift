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
}

class WordFrequenciesListViewController: UIViewController {
  
  // MARK: UI
  
  private let tableView = UITableView()
  private var tableViewDataSource: UITableViewDiffableDataSource<Int, WordFrequenciesCellConfiguration>?
  
  private let viewModel: WordFrequenciesListViewModelProtocol
  
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
    setBindings()
  }
  
}

// MARK: - Bindings

private extension WordFrequenciesListViewController {
  
  private func setBindings() {
    let output = viewModel.bind(input: .init())
    
    output.cellConfigurations
      .sink { [tableViewDataSource] configurations in
        var snapshot = NSDiffableDataSourceSnapshot<Int, WordFrequenciesCellConfiguration>()
        snapshot.appendSections([0])
        snapshot.appendItems(configurations)
        tableViewDataSource?.apply(snapshot)
      }
      .store(in: &disposeBag)
  }
  
}

// MARK: Views Setup

private extension WordFrequenciesListViewController {
  
  func setHierarchy() {
    view.addSubview(tableView)
  }
  
  func setUI() {
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
      return cell
    })
  }
  
  func setLayout() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
}
