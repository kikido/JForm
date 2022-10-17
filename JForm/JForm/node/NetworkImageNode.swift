//
//  NetworkImageNode.swift
//  JForm
//
//  Created by dqh on 2022/10/11.
//

import Foundation
import AsyncDisplayKit

public struct NetworkImageErrorHelper: NetworkImageHelper  {
    
    public func isCached(forKey key: String) -> Bool {
        fatalError("you should implemente the protocol NetworkImageHelper")
    }
    
    public func retrieveImage(forKey key: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        fatalError("you should implemente the protocol NetworkImageHelper")
    }

    public func setImageWithURL(forImageView imageView: UIImageView, imageURL: URL, placeholder: UIImage?) {
        fatalError("you should implemente the protocol NetworkImageHelper")
    }
}

public class NetworkImageNode: ASDisplayNode {

    public static var helper: NetworkImageHelper = NetworkImageErrorHelper()

    public let imageNode: ASImageNode
    public let networkImageNode: ASDisplayNode
    
    // 是否来自本地图片。网络优先级 > 本地
    private(set) public var isFormLocal: Bool

    public var placeholder: String?
    
    public var URL: URL? {
        willSet {
            defer {
                self.setNeedsLayout()
            }
            if let u = newValue {
                if NetworkImageNode.helper.isCached(forKey: u.absoluteString) {
                    isFormLocal = true
                    NetworkImageNode.helper.retrieveImage(forKey: u.absoluteString) { result in
                        switch result {
                        case .success(let value):
                            self.imageNode.image = value
                        case .failure:
                            break
                        }
                    }
                } else {
                    isFormLocal = false
                    if self.isNodeLoaded {
                        let imageView = self.networkImageNode.view as! UIImageView
                        NetworkImageNode.helper.setImageWithURL(
                            forImageView: imageView,
                            imageURL: u,
                            placeholder: placeholder == nil ? nil : UIImage(named: placeholder!)
                        )
                    }
                }
            } else {
                isFormLocal = true
            }
        }
    }
        
    var imageName: String? {
        willSet {
            // 当有网络图片时，忽略这个设置
            if let name = newValue, isFormLocal {
                imageNode.image = UIImage(named: name)
            }
        }
    }
    
    var image: UIImage? {
        willSet {
            // 当有网络图片时，忽略这个设置
            if isFormLocal {
                imageNode.image = newValue
            }
        }
    }
    
    public init(placeholder: String? = nil) {
        self.placeholder = placeholder
        isFormLocal = true
        
        networkImageNode = ASDisplayNode.init { UIImageView() }
        imageNode = ASImageNode()
        
        super.init()

        self.automaticallyManagesSubnodes = true
    }
    
    public override func didLoad() {
        if let imageView = networkImageNode.view as? UIImageView, let URL = URL {
            NetworkImageNode.helper.setImageWithURL(
                forImageView: imageView,
                imageURL: URL,
                placeholder: placeholder == nil ? nil : UIImage(named: placeholder!)
            )
        }
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: .zero, child: isFormLocal ? imageNode: networkImageNode)
    }
}
