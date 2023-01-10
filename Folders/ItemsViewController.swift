//
//  ItemsViewController.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 07/01/2023.
//

import UIKit
import Combine

final class ItemsViewController: UIViewController, MessagePresenter, LoadingViewPresenter, ImagePickerPresenter {

    private lazy var tableView: UITableView = {
        let tableView =  UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.cellIdentifer)
        tableView.delegate = self
        return tableView
    }()

    private lazy var addButton: UIBarButtonItem = {
        let createFolderAction = UIAction(
            title: "Create a folder",
            image: UIImage(systemName: "folder.badge.plus")) { [weak self] _ in
                self?.createFolder()
        }

        let uploadFromPhotoLibraryAction = UIAction(
            title: "Upload from the photo library",
            image: UIImage(systemName: "photo")) { [weak self] _ in
                self?.uploadPicture(sourceType: .photoLibrary)
        }

        let uploadFromCameraAction = UIAction(
            title: "Upload from camera",
            image: UIImage(systemName: "camera")) { [weak self] _ in
                self?.uploadPicture(sourceType: .camera)
        }

        return UIBarButtonItem(
            systemItem: .add,
            primaryAction: nil,
            menu: UIMenu(children: [createFolderAction, uploadFromPhotoLibraryAction, uploadFromCameraAction]))
    }()

    private var dataSource: ItemsDiffableDataSource!

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
        navigationItem.rightBarButtonItem = addButton

        configureTableView()
        configureRefreshControl()

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSate in
                guard let self = self else { return }
                switch newSate {
                case let .initial(viewState):
                    self.update(with: viewState)
                case .loading:
                    self.presentLoadingView()
                case .adding:
                    self.presentLoadingView()
                case .deleting:
                    break
                case let .updated(viewState):
                    self.removeLoadingView()
                    self.tableView.refreshControl?.endRefreshing()
                    self.update(with: viewState)
                case let .failure(error):
                    self.removeLoadingView()
                    self.tableView.refreshControl?.endRefreshing()
                    self.presentError(error)
                }
            }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
        viewModel.fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)

        tableView.refreshControl = refreshControl
    }

    private func configureTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        dataSource = ItemsDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.cellIdentifer, for: indexPath) as? ItemCell
            cell?.item = item
            return cell
        }

        dataSource.deleteHandler = { [weak self] item in
            self?.viewModel.deleteItem(with: item.itemId)
        }

        dataSource.defaultRowAnimation = .none
        tableView.backgroundColor = .systemBackground
    }

    private func update(with viewState: ItemsViewState) {
        title = viewState.title
        dataSource.update(with: viewState.items)
    }

    private func createFolder() {
        presentInput(
            title: "Create folder".localized,
            message: nil,
            placeholder: "Enter folder name".localized) { [weak self] folderName in
                guard let folderName = folderName else {
                    return
                }
                self?.viewModel.createFolder(name: folderName)
            }
    }

    private func uploadPicture(sourceType: ImagePickerSource) {
#if targetEnvironment(simulator)
        guard sourceType == .photoLibrary else {
            presentError("This feature works on a real device only.")
            return
        }
#endif
        presentImagePicker(sourceType: sourceType) { [weak self] data in
            guard let data = data else {
                return
            }

            self?.presentInput(
                title: "Upload picture",
                message: nil,
                placeholder: "Enter picture name") { name in
                    guard let name = name else {
                        return
                    }

                    self?.viewModel.uploadFile(name: name, data: data)
                }
        }
    }

    @objc func refreshControlAction(_ sender: AnyObject) {
        viewModel.fetch(isRefresh: true)
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

final class ItemsDiffableDataSource: UITableViewDiffableDataSource<ItemsDiffableDataSource.Section, ItemViewState> {

    enum Section {
        case main
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    var deleteHandler: ((ItemViewState) -> Void)?

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let item = (tableView.cellForRow(at: indexPath) as? ItemCell)?.item else {
            assertionFailure("Missing item")
            return
        }
        deleteHandler?(item)
    }

    func update(with items: [ItemViewState]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemViewState>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        self.apply(snapshot)
    }
}
