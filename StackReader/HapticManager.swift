//
//  HapticManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-05.
//

import UIKit

class HapticManager: NSObject {
    
    static let shared = HapticManager()
    
    private var generators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [
        .light : UIImpactFeedbackGenerator(style: .light),
        .medium: UIImpactFeedbackGenerator(style: .medium),
        .heavy: UIImpactFeedbackGenerator(style: .heavy)
    ]
    private let notifHaptic = UINotificationFeedbackGenerator()
    private var lastFired = TimeInterval()
    
    private override init() {
        generators[.light]?.prepare()
        generators[.medium]?.prepare()
        generators[.heavy]?.prepare()
        notifHaptic.prepare()
    }
    
    func fire(impactStyle: UIImpactFeedbackGenerator.FeedbackStyle? = .light,
              notifStyle: UINotificationFeedbackGenerator.FeedbackType? = nil,
              intensity: CGFloat = 1.0) {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            guard CACurrentMediaTime() - s.lastFired > 0.1 else { return }
            s.lastFired = CACurrentMediaTime()
            switch impactStyle {
            case .light, .medium, .heavy:
                s.generators[impactStyle ?? .light]?.impactOccurred(intensity: intensity)
            default:
                s.notifHaptic.notificationOccurred(notifStyle ?? .success)
            }
        }
    }
    
}
