//
//  NetworkImageHelper.swift
//  JForm
//
//  Created by dqh on 2022/10/11.
//

import UIKit

public protocol NetworkImageHelper {
        
    func isCached(forKey key: String) -> Bool
    
    func retrieveImage(forKey key: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void)

    func setImageWithURL(forImageView imageView: UIImageView, imageURL: URL, placeholder: UIImage?)

}
