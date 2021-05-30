//
//  Extension+String.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

// MARK: - String

extension String {
    
    static var uuid: String {
        return UUID().uuidString
    }
    
    func heightFor(width: CGFloat, using font: UIFont) -> CGFloat {
        return NSString(string: self).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [NSStringDrawingOptions.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).height
    }
    
}
