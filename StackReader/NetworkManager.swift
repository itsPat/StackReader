//
//  NetworkManager.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import Foundation

class NetworkManager {
    
    enum NetworkError: Error {
        case invalidUrl, failedToParseResponse
    }
    
    // MARK: - Singleton declaration
    
    static let shared = NetworkManager()
    private init() {}
    
    
    // MARK: - Fetch Publications by Substack Category
    
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
            
            if let data = data,
               let response = try? JSONDecoder().decode(Substack.PublicationsByCategoryResponse.self, from: data) {
                return completion(.success(response.publications))
            } else {
                return completion(.failure(NetworkError.failedToParseResponse))
            }
        }.resume()
    }
    
}
