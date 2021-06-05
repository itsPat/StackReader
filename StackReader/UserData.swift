//
//  UserData.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-06-02.
//

import Foundation

class UserData {

    // MARK: - Publications
    
    static var savedPublications: [Substack.Publication] {
        guard let data = UserDefaults.standard.data(forKey: "savedPublications"),
           let publications = try? JSONDecoder().decode([Substack.Publication].self, from: data) else { return [] }
        savedPublicationById = [:]
        for p in publications { savedPublicationById[p.id] = p }
        return publications
    }
    
    static var savedPublicationById: [Int: Substack.Publication] = [:]
    
    static func add(publication: Substack.Publication) {
        do {
            let data = try JSONEncoder().encode(
                savedPublications.contains(publication) ? savedPublications : savedPublications + [publication]
            )
            savedPublicationById[publication.id] = publication
            UserDefaults.standard.set(data, forKey: "savedPublications")
        } catch {
            print("Failed to add publication to stacks: \(publication)")
        }
    }
    
    static func remove(publication: Substack.Publication) {
        do {
            var publications = savedPublications
            publications.removeAll(where: { $0.id == publication.id })
            let data = try JSONEncoder().encode(publications)
            savedPublicationById[publication.id] = nil
            UserDefaults.standard.set(data, forKey: "savedPublications")
        } catch {
            print("Failed to remove publication from saved: \(publication)")
        }
    }
    
    // MARK: - Posts
    
    static var savedPosts: [Substack.Post] {
        guard let data = UserDefaults.standard.data(forKey: "savedPosts"),
           let posts = try? JSONDecoder().decode([Substack.Post].self, from: data) else { return [] }
        return posts
    }
    
    static func add(post: Substack.Post) {
        do {
            let data = try JSONEncoder().encode(
                savedPosts.contains(post) ? savedPosts : savedPosts + [post]
            )
            UserDefaults.standard.set(data, forKey: "savedPosts")
        } catch {
            print("Failed to add publication to stacks: \(post)")
        }
    }
    
    static func remove(post: Substack.Post) {
        do {
            var posts = savedPosts
            posts.removeAll(where: { $0.id == post.id })
            let data = try JSONEncoder().encode(posts)
            UserDefaults.standard.set(data, forKey: "savedPosts")
        } catch {
            print("Failed to remove post from saved: \(post)")
        }
    }
    
}
