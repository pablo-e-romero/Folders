//
//  ItemsViewController.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 07/01/2023.
//

import UIKit
import Combine

final class ItemsViewController: UIViewController, MessagePresenter {

    enum Section {
        case main
    }

    private lazy var tableView: UITableView = {
        let tableView =  UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.cellIdentifer)
        tableView.delegate = self
        return tableView
    }()

    private var dataSource: UITableViewDiffableDataSource<Section, ItemViewState>!

    private var loadingView: LoadingView?
    private let viewModel: ItemsViewModel
    private var cancellables = Set<AnyCancellable>()

    var showChildItemCallback: ((ItemViewState) -> Void)?

    init(viewModel: ItemsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        dataSource = UITableViewDiffableDataSource<Section, ItemViewState>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.cellIdentifer, for: indexPath) as? ItemCell
            cell?.item = item
            return cell
        }
        
        dataSource.defaultRowAnimation = .none

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSate in
                guard let self = self else { return }
                switch newSate {
                case let .initial(viewState):
                    self.update(with: viewState)
                    self.showLoading()
                case .loading:
                   break
                case let .uploading(progress):
                    print("uploading \(progress)")
                case let .updated(viewState):
                    self.loadingView?.removeFromSuperview()
                    self.update(with: viewState)
                case let .failure(error):
                    self.loadingView?.removeFromSuperview()
                    self.presentError(error)
                }
            }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func update(with viewState: ItemsViewState) {
        title = viewState.title
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemViewState>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewState.items, toSection: .main)
        dataSource.apply(snapshot)
    }

    private func showLoading() {
        guard self.loadingView == nil else { return }
        self.loadingView = LoadingView.createAndShow(on: self.view)
    }

}

extension ItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = (tableView.cellForRow(at: indexPath) as? ItemCell)?.item else {
            assertionFailure("Missing item")
            return
        }
        self.showChildItemCallback?(item)
    }
}

