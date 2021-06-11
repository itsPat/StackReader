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
        case invalidUrl, failedToParseResponse, noData, requiresLogin
    }
    
    static let shared = NetworkManager()
    private init() {}
    
    private var tasks = [String: URLSessionDataTask]()
    
    // MARK: - Cancel Network Tasks
    
    func cancel(taskWithId taskId: String) {
        tasks[taskId]?.cancel()
        tasks[taskId] = nil
    }
    
    
    // MARK: - Fetch Image for URL
    
    func fetchImage(with url: String,
                    taskId: String = .uuid,
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
        tasks[taskId] = task
    }
    
    
    // MARK: - Search Publications
    
    func searchPublications(query: String, page: Int = 0, completion: @escaping (Result<[Substack.Publication], Error>) -> ()) {
        guard let encodedQuery = query
                .lowercased()
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://substack.com/api/v1/publication/search?query=\(encodedQuery)&page=\(page)") else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                return completion(.failure(err))
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(Substack.PublicationSearchResponse.self, from: data)
                    return completion(.success(response.results))
                } catch {
                    return completion(.failure(error))
                }
            } else {
                print("❌ Failed to parse response: \(url)")
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
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
    
    // MARK: - Login to Substack
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> ()) {
        let values = ["email": email, "password": password]
        guard let url = URL(string: "https://substack.com/api/v1/login"),
              let body = try? JSONSerialization.data(withJSONObject: values, options: []) else {
            return completion(.failure(NetworkError.invalidUrl))
        }
        var req = URLRequest(url: url)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        req.httpBody = body
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                completion(.failure(err))
            } else if let res = res as? HTTPURLResponse,
                      res.statusCode == 200 {
                completion(.success(()))
            }
        }.resume()
    }
    
    
    // MARK: - Fetch Feed for logged in user
    
    func fetchFeed(page: Int = 0, completion: @escaping (Result<[Substack.Post], Error>) -> ()) {
        guard let url = URL(string: "https://reader.substack.com/api/v1/reader/posts?page=\(page)&type=post") else { return }
        URLSession.shared.dataTask(with: url) { (data, res, err) in
            if let err = err {
                return completion(.failure(err))
            }
            if let data = data,
               let response = try? JSONDecoder().decode(Substack.PostsFeedResponse.self, from: data) {
                return completion(.success(response.posts))
            } else {
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
    }
    
}
