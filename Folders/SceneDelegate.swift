//
//  SceneDelegate.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 07/01/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var itemsCoordinator: ItemsCoordinator?
    var dependenciesContaier: DependenciesContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let navController = UINavigationController()
        let dependenciesContainer: DependenciesContainer = .live

        let coordinator = ItemsCoordinator(
            navController: navController,
            context: dependenciesContainer)

        window.rootViewController = navController
        window.makeKeyAndVisible()

        coordinator.start(animated: true)

        self.window = window
        self.itemsCoordinator = coordinator
        self.dependenciesContaier = dependenciesContainer
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }

}
