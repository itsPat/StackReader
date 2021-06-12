//
//  Extensions+Double.swift
//  magicollab
//
//  Created by Pat Trudel on 2021-02-15.
//  Copyright © 2021 Pat Trudel. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWithAnimation(image: UIImage?, mode: UIView.ContentMode = .scaleAspectFill) {
        guard let image = image else { return }
        DispatchQueue.main.async { [weak self] in
            self?.contentMode = mode
            guard let `self` = self else { return }
            UIView.transition(with: self,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: { self.image = image },
                              completion: nil)
        }
    }
    
    func setImageWith(url: String?, cellId: String = .uuid) {
        if let url = url {
            ImageManager.shared.getImage(with: url, taskId: cellId) { [weak self] (res) in
                switch res {
                case .success(let tuple):
                    if tuple.isLocalFetch {
                        DispatchQueue.main.async { [weak self] in
                            self?.preferredSymbolConfiguration = .unspecified
                            self?.contentMode = .scaleAspectFill
                            self?.image = tuple.image
                        }
                    } else {
                        self?.setImageWithAnimation(image: tuple.image)
                    }
                case .failure(let err) where (err as NSError).code != -999:
                    print("\(#function) failed with err: \(err)")
                default:
                    break
                }
            }
        }
    }
    
}
