//
//  ItemsViewModelTests.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 07/01/2023.
//

import XCTest
import Combine
@testable import Folders

final class ItemsViewModelTests: XCTestCase {
    var subscriptions = Set<AnyCancellable>()

    override func tearDownWithError() throws {
        subscriptions = []
    }

    func testFetchItems() throws {
        let requestMapper = APIRequestMapperBuilder()
            .append(
                httpMethod: .get,
                urlPattern: "/items",
                response: .content(filename: "Items")
            )
            .build()

        let dependenciesContainer: DependenciesContainer = .mock(
            requestMapper: requestMapper
        )

        let viewModel = dependenciesContainer.newItemsViewModel(
            parentItem: MockData.parentItemViewState
        )

        var states = [ItemsViewModel.State]()

        viewModel
            .statePublisher
            .sink { states.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(states.count, 0)

        viewModel.viewDidLoad()

        XCTAssertEqual(states.count, 1)

        guard case let .initial(viewState) = states[0] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.title, MockData.parentItemViewState.name)

        viewModel.fetch()

        XCTAssertEqual(states.count, 3)

        guard case .loading = states[1] else {
            XCTFail("Invalid state")
            return
        }

        guard case let .updated(viewState) = states[2] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 7)
    }

    func testAddFolder() throws {
        let requestMapper = APIRequestMapperBuilder()
            .append(
                httpMethod: .get,
                urlPattern: "/items",
                response: .content(filename: "Items")
            )
            .append(
                httpMethod: .post(nil),
                urlPattern: "/items",
                response: .content(filename: "AddFolder")
            )
            .build()

        let dependenciesContainer: DependenciesContainer = .mock(
            requestMapper: requestMapper
        )

        let viewModel = dependenciesContainer.newItemsViewModel(
            parentItem: MockData.parentItemViewState
        )

        var states = [ItemsViewModel.State]()

        viewModel
            .statePublisher
            .sink { states.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(states.count, 0)

        viewModel.viewDidLoad()
        viewModel.fetch()

        XCTAssertEqual(states.count, 3)

        guard case let .updated(viewState) = states[2] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 7)

        viewModel.createFolder(name: "a")

        XCTAssertEqual(states.count, 5)

        guard case .adding = states[3] else {
            XCTFail("Invalid state")
            return
        }

        guard case let .updated(viewState) = states[4] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 8)
    }

    func testAddDuplicatedFolder() throws {
        let requestMapper = APIRequestMapperBuilder()
            .append(
                httpMethod: .get,
                urlPattern: "/items",
                response: .content(filename: "Items")
            )
            .append(
                httpMethod: .post(nil),
                urlPattern: "/items",
                response: .error(filename: "DuplicatedItemError", statusCode: 400)
            )
            .build()

        let dependenciesContainer: DependenciesContainer = .mock(
            requestMapper: requestMapper
        )

        let viewModel = dependenciesContainer.newItemsViewModel(
            parentItem: MockData.parentItemViewState
        )

        var states = [ItemsViewModel.State]()

        viewModel
            .statePublisher
            .sink { states.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(states.count, 0)

        viewModel.viewDidLoad()
        viewModel.fetch()

        XCTAssertEqual(states.count, 3)

        guard case let .updated(viewState) = states[2] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 7)

        viewModel.createFolder(name: "a")

        XCTAssertEqual(states.count, 5)

        guard case .adding = states[3] else {
            XCTFail("Invalid state")
            return
        }

        guard case let .failure(error) = states[4] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(error.localizedDescription, "Item already exists (400).")
    }

    func testAddItem() throws {
        let requestMapper = APIRequestMapperBuilder()
            .append(
                httpMethod: .get,
                urlPattern: "/items",
                response: .content(filename: "Items")
            )
            .append(
                httpMethod: .post(nil),
                urlPattern: "/items",
                response: .content(filename: "AddItem")
            )
            .build()

        let dependenciesContainer: DependenciesContainer = .mock(
            requestMapper: requestMapper
        )

        let viewModel = dependenciesContainer.newItemsViewModel(
            parentItem: MockData.parentItemViewState
        )

        var states = [ItemsViewModel.State]()

        viewModel
            .statePublisher
            .sink { states.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(states.count, 0)

        viewModel.viewDidLoad()
        viewModel.fetch()

        XCTAssertEqual(states.count, 3)

        guard case let .updated(viewState) = states[2] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 7)

        viewModel.createFolder(name: "a")

        XCTAssertEqual(states.count, 5)

        guard case .adding = states[3] else {
            XCTFail("Invalid state")
            return
        }

        guard case let .updated(viewState) = states[4] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 8)
    }

    func testDeleteItem() throws {
        let requestMapper = APIRequestMapperBuilder()
            .append(
                httpMethod: .get,
                urlPattern: "/items",
                response: .content(filename: "Items")
            )
            .append(
                httpMethod: .delete,
                urlPattern: "/items",
                response: .content(filename: "Delete")
            )
            .build()

        let dependenciesContainer: DependenciesContainer = .mock(
            requestMapper: requestMapper
        )

        let viewModel = dependenciesContainer.newItemsViewModel(
            parentItem: MockData.parentItemViewState
        )

        var states = [ItemsViewModel.State]()

        viewModel
            .statePublisher
            .sink { states.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(states.count, 0)

        viewModel.viewDidLoad()
        viewModel.fetch()

        XCTAssertEqual(states.count, 3)

        guard case let .updated(viewState) = states[2] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 7)

        viewModel.deleteItem(with: "fe1b2eb74946b3bad2adab897b05d2e0b814cb33")

        XCTAssertEqual(states.count, 5)

        guard case .deleting = states[3] else {
            XCTFail("Invalid state")
            return
        }

        guard case let .updated(viewState) = states[4] else {
            XCTFail("Invalid state")
            return
        }

        XCTAssertEqual(viewState.items.count, 6)
    }

}
