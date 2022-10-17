//
//  AppDelegate.swift
//  JForm
//
//  Created by dqh on 2021/7/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // config
        NetworkImageNode.helper = NetworkImageTestHelper()
        
        let rootVC = UINavigationController.init(rootViewController: ViewController())
        //
        
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.backgroundColor = .white
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

func netImageUrl(width: Int = 40, height: Int = 40) -> URL {
    return URL(string: "https://placekitten.com/g/\(width)/\(height)")!
}

struct NetworkImageTestHelper: NetworkImageHelper {
    
    func isCached(forKey key: String) -> Bool {
        return ImageCache.default.isCached(forKey: key)
    }
    
    func retrieveImage(forKey key: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        ImageCache.default.retrieveImage(forKey: key) { kfResult in
            switch kfResult {
            case .success(let value):
                if value.cacheType != .none, let image = value.image {
                    completionHandler(.success(image))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func setImageWithURL(forImageView imageView: UIImageView, imageURL: URL, placeholder: UIImage?) {
        imageView.kf.setImage(with: imageURL, placeholder: placeholder)
    }
}

