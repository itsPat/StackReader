//
//  Substack+Post.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import Foundation
import UIKit

extension Substack {
    
    // MARK: - Fetch Feed Response
    
    struct PostsFeedResponse: Codable {
        let posts: [Post]
        
        /// True if there are more pages for this category.
        let more: Bool
    }

    struct Post: Codable, Hashable {
        
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
            audience == "only_paid"
        }
        
        var isSupportedType: Bool {
            type == "podcast" || type == "newsletter"
        }
        
        var isNewsletter: Bool {
            type == "newsletter"
        }
        
        private enum CodingKeys: String, CodingKey {
            case id, slug, audience, title, subtitle, description, type, publication
            case postDateString = "post_date"
            case canonicalUrl = "canonical_url"
            case coverImageUrl = "cover_image"
            case podcastUrl = "podcast_url"
            case podcastDuration = "podcast_duration"
            case bodyHtml = "body_html"
        }
        
        var isSaved: Bool {
            UserData.savedPosts.contains(self)
        }
        
        var saveActionTitle: String {
            isSaved ? "Remove Post" : "Save Post"
        }
        
        var saveActionImage: UIImage? {
            UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark")
        }
        
        func saveAction(completion: @escaping (() -> ()) = {}) -> UIAction {
            UIAction(title: saveActionTitle, image: saveActionImage) { _ in
                toggleIsSaved()
                completion()
            }
        }
        
        func toggleIsSaved() {
            if isSaved {
                UserData.remove(post: self)
            } else {
                UserData.add(post: self)
            }
        }
    }
    
}
