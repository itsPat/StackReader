//
//  Substack+Item.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-24.
//

import Foundation

extension Substack {
    
    enum Item: Hashable {
        case post(Substack.Post)
        case publication(Substack.Publication)
        case ad(UUID = UUID())
    }
    
}
