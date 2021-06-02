//
//  Substack+Publication.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import Foundation

extension Substack {
    
    // MARK: - Publications By Category Response
    
    struct PublicationsByCategoryResponse: Codable {
        let publications: [Publication]
        
        /// True if there are more pages for this category.
        let more: Bool
    }

    struct Publication: Codable {
        
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
        
    }
    
}
