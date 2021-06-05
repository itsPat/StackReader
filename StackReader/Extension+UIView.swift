//
//  Extension+UIView.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-05.
//

import UIKit

extension UIView {
    
    func pulse(completion: @escaping () -> () = {}) {
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.25) {
                self?.transform = .identity
            } completion: { (_) in
                HapticManager.shared.fire(impactStyle: .light, intensity: 0.5)
                completion()
            }
        }
    }
    
}
