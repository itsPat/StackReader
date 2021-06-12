//
//  Substack+Publication.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import Foundation
import UIKit

extension Substack {
    
    // MARK: - Publications By Category Response
    
    struct PublicationsByCategoryResponse: Codable {
        let publications: [Publication]
        
        /// True if there are more pages for this category.
        let more: Bool
    }
    
    // MARK: - Publication Search Response
    
    struct PublicationSearchResponse: Codable {
        let results: [Publication]
        
        /// True if there are more pages for this category.
        let more: Bool
    }

    struct Publication: Codable, Hashable {
        
        let id: Int
        let subdomain: String
        let hostname: String
        let baseUrl: String
        
        let name: String
        let description: String?
        let logoUrl: String?
        
        let authorId: Int
        let authorName: String?
        let authorBio: String?
        let authorPhotoUrl: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, subdomain, hostname, name
            case logoUrl = "logo_url"
            case authorId = "author_id"
            case description = "hero_text"
            case authorName = "author_name"
            case authorPhotoUrl = "author_photo_url"
            case authorBio = "author_bio"
            case baseUrl = "base_url"
        }
        
        var isSaved: Bool {
            UserData.savedPublications.contains(self)
        }
        
        var saveActionTitle: String {
            isSaved ? "Remove from Stacks" : "Add to Stacks"
        }
        
        var saveActionImage: UIImage? {
            UIImage(systemName: isSaved ? "minus.circle" : "plus.circle")
        }
        
        func saveAction(completion: @escaping (() -> ()) = {}) -> UIAction {
            UIAction(title: saveActionTitle, image: saveActionImage) { _ in
                toggleIsSaved()
                completion()
            }
        }
        
        func toggleIsSaved() {
            if isSaved {
                UserData.remove(publication: self)
            } else {
                UserData.add(publication: self)
            }
        }
    }
    
}
