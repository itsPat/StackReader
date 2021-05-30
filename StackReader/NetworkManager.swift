//
//  NetworkManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import Foundation
import UIKit

class NetworkManager {
    
    enum NetworkError: Error {
        case invalidUrl, failedToParseResponse, noData
    }
    
    // MARK: - Singleton declaration
    
    static let shared = NetworkManager()
    private init() {}
    var tasks = [String: URLSessionDataTask]()
    
    // MARK: - Fetch Image for URL
    
    func fetchImage(with url: String,
                    cellId: String = .uuid,
                    completion: @escaping (Result<UIImage, Error>) -> ()) {
        guard let url = URL(string: url) else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        let task = URLSession.shared.dataTask(with: url) { data, res, err in
            if let error = err {
                completion(.failure(error))
            } else if let data = data,
                      let image = UIImage(data: data) {
                completion(.success(image))
            }
        }
        task.resume()
        tasks[cellId] = task
    }
    
    // MARK: - Fetch Discover Page Data
    
    func fetchDiscoverPageData(completion: @escaping (Result<[Substack.Category: [Substack.Publication]], Error>) -> ()) {
        let group = DispatchGroup()
        var discoverPageData = [Substack.Category: [Substack.Publication]]()
        Substack.Category.allCases.forEach { category in
            group.enter()
            NetworkManager.shared.fetchPublications(by: category) { (res) in
                switch res {
                case .success(let publications):
                    discoverPageData[category] = publications
                case .failure(let err):
                    print("\(#function) failed to get data for category: \(category) with error: \(err)")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(discoverPageData.isEmpty ? .failure(NetworkError.noData) : .success(discoverPageData))
        }
    }
    
    // MARK: - Fetch Publications for Category
    
    func fetchPublications(by category: Substack.Category,
                           page: Int = 0,
                           completion: @escaping (Result<[Substack.Publication], Error>) -> ()) {
        guard let url = URL(string: "https://substack.com/api/v1/category/public/\(category.id)/all?page=\(page)") else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                return completion(.failure(err))
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Substack.PublicationsByCategoryResponse.self, from: data)
                    return completion(.success(response.publications))
                } catch {
                    return completion(.failure(error))
                }
            } else {
                print("❌ Failed to parse response: \(url)")
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
    }
    
    // MARK: - Fetch Posts for Publication
    
    /// This method returns only the generic metadata for the given post.
    /// You must fetch details for the post in order to get the content data.
    func fetchPosts(for publication: Substack.Publication,
                    offset: Int = 0,
                    completion: @escaping (Result<[Substack.Post], Error>) -> ()) {
        guard let url = URL(string: publication.baseUrl + "/api/v1/archive?sort=new&offset=\(offset)&limit=20") else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                return completion(.failure(err))
            }
            
            if let data = data,
               let posts = try? JSONDecoder().decode([Substack.Post].self, from: data) {
                return completion(.success(posts.compactMap {
                    var post = $0
                    post.publication = publication
                    return post
                }))
            } else {
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
    }
    
    // MARK: - Fetch Details for Post
    
    /// Fetches the content for the given post.
    func fetchDetails(for post: Substack.Post,
                      completion: @escaping (Result<Substack.Post, Error>) -> ()) {
        guard let url = URL(string: post.postDetailUrl ?? "") else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                return completion(.failure(err))
            }
            
            if let data = data,
               let post = try? JSONDecoder().decode(Substack.Post.self, from: data) {
                return completion(.success(post))
            } else {
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
    }
    
}
