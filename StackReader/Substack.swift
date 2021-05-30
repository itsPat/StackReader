//
//  Substack.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import Foundation

class Substack {
    
    // MARK: - Substack Categories
    
    enum Category: String, CaseIterable {
        
        case culture = "Culture"
        case politics = "Politics"
        case technology = "Technology"
        case business = "Business"
        case finance = "Finance"
        case food = "Food & Drink"
        case sports = "Sports"
        case faith = "Faith"
        case news = "News"
        case music = "Music"
        case literature = "Literature"
        case art = "Art"
        case climate = "Climate"
        case science = "Science"
        case health = "Health"
        case philosophy = "Philosophy"
        case history = "History"
        case travel = "Travel"
        case education = "Education"
        
        
        
        var id: Int {
            switch self {
            case .culture: return 96
            case .politics: return 14
            case .technology: return 4
            case .business: return 62
            case .finance: return 153
            case .food: return 13645
            case .sports: return 94
            case .faith: return 223
            case .news: return 103
            case .music: return 11
            case .literature: return 339
            case .art: return 15417
            case .climate: return 15414
            case .science: return 134
            case .health: return 355
            case .philosophy: return 114
            case .history: return 18
            case .travel: return 109
            case .education: return 34
            }
        }
        
    }
    
    // MARK: - Publications By Category Response
    
    struct PublicationsByCategoryResponse: Codable {
        let publications: [Publication]
        
        /// True if there are more pages for this category.
        let more: Bool
    }
    
    // MARK: - Publication
    
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
    
    // MARK: - Post
    
    struct Post: Codable {
        
        let id: Int
        let slug: String
        let audience: String // "everyone"
        let title: String
        let subtitle: String
        let description: String
        let type: String // "thread", "podcast", "newsletter"
        let postDateString: String
        let canonicalUrl: String?
        let coverImageUrl: String?
        let podcastUrl: String?
        let podcastDuration: Float?
        let bodyHtml: String?
        var publication: Substack.Publication?
        
        var postUrl: String? {
            guard let publication = publication else { return nil }
            return "https://\(publication.subdomain).substack.com/p/\(slug)"
        }
        
        var postDetailUrl: String? {
            guard let publication = publication else { return nil }
            return "https://\(publication.subdomain).substack.com/api/v1/posts/\(slug)"
        }
        
        var isPaidOnly: Bool {
            return audience == "only_paid"
        }
        
        var isSupportedType: Bool {
            return type == "podcast" || type == "newsletter"
        }
        
        private enum CodingKeys: String, CodingKey {
            case id, slug, audience, title, subtitle, description, type
            case postDateString = "post_date"
            case canonicalUrl = "canonical_url"
            case coverImageUrl = "cover_image"
            case podcastUrl = "podcast_url"
            case podcastDuration = "podcast_duration"
            case bodyHtml = "body_html"
        }
        
    }
    
}

