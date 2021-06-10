//
//  ImageManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class ImageManager: NSObject {

    static let shared = ImageManager()
    private var imageCache = NSCache<NSString, UIImage>()
    
    func getImage(with url: String,
                  taskId: String = .uuid,
                  completion: ((Result<(image: UIImage, isLocalFetch: Bool), Error>) -> ())? = nil) {
        if let localImage = imageCache.object(forKey: url as NSString) {
            completion?(.success((image: localImage, isLocalFetch: true)))
        } else {
            NetworkManager.shared.fetchImage(with: url, taskId: taskId) { [weak self] (result) in
                switch result {
                case .success(let image):
                    self?.imageCache.setObject(image, forKey: url as NSString)
                    completion?(.success((image: image, isLocalFetch: false)))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }
    
}
