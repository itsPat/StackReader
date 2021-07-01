//
//  Extension+UIView.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-05.
//

import UIKit

extension UIView {
    
    func pulse(completion: @escaping () -> () = {}) {
        HapticManager.shared.fire(impactStyle: .light)
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                self?.transform = .identity
            } completion: { (_) in
                completion()
            }
        }
    }
    
}
