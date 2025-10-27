//
//  SceneDelegate.swift
//  CombineStudying
//
//  Created by Orest Palii on 24.10.2025.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var cancellable: AnyCancellable?
    let authObserver = AuthObserver()
    let authService = CDAuthService(config: CoreDataConfig())

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = AuthViewController(authObserver: authObserver, authService: authService)
        window?.makeKeyAndVisible()
        
        cancellable = authObserver.$isUserAuthentificated
            .sink(
                receiveValue: {[weak self] isUserAuth in
                    if let self{
                        //TAB Items
                        let tabVC = UITabBarController()
                        let discoverTabNavVC = UINavigationController(
                            rootViewController:
                                DiscoverMoviesViewController(
                                    movieService: MovieService(),
                                    imgLoadingService: ImageLoaderService(),
                                    cdMovieService: CDMoviesService(authService: authService)
                                )
                        )
                        discoverTabNavVC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass"), tag: 1)
                        
                        let profileTabNavVC = UINavigationController(rootViewController: ProfileViewController())
                        profileTabNavVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
                        
                        tabVC.viewControllers = [discoverTabNavVC, profileTabNavVC]
                        
                        //Auth checking
                        var vcForDisplay: UIViewController
                        if isUserAuth{
                            vcForDisplay = tabVC
                        }else{
                            vcForDisplay = AuthViewController(authObserver: self.authObserver, authService: authService)
                        }
                        
                        self.window?.rootViewController = vcForDisplay
                    }
                }
            )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

