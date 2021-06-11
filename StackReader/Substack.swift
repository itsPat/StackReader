//
//  Substack.swift
//  StackReader
//
//  Created by Patrick Trudel on 2021-05-30.
//

import UIKit

class Substack {
    
    // MARK: - Substack Categories
    
    enum Category: String, CaseIterable {
        
        case art = "Art"
        case business = "Business"
        case climate = "Climate"
        case culture = "Culture"
        case education = "Education"
        case faith = "Faith"
        case finance = "Finance"
        case food = "Food & Drink"
        case health = "Health"
        case history = "History"
        case literature = "Literature"
        case music = "Music"
        case news = "News"
        case philosophy = "Philosophy"
        case politics = "Politics"
        case science = "Science"
        case sports = "Sports"
        case technology = "Technology"
        case travel = "Travel"
        
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
        
        var icon: UIImage? {
            switch self {
            case .culture: return UIImage(systemName: "person")
            case .politics: return UIImage(systemName: "building.columns")
            case .technology: return UIImage(systemName: "iphone")
            case .business: return UIImage(systemName: "briefcase")
            case .finance: return UIImage(systemName: "banknote")
            case .food: return UIImage(systemName: "cart")
            case .sports: return UIImage(systemName: "megaphone")
            case .faith: return UIImage(systemName: "lightbulb")
            case .news: return UIImage(systemName: "newspaper")
            case .music: return UIImage(systemName: "music.mic")
            case .literature: return UIImage(systemName: "book")
            case .art: return UIImage(systemName: "paintbrush.pointed")
            case .climate: return UIImage(systemName: "thermometer.sun")
            case .science: return UIImage(systemName: "eyedropper")
            case .health: return UIImage(systemName: "cross")
            case .philosophy: return UIImage(systemName: "questionmark")
            case .history: return UIImage(systemName: "hourglass")
            case .travel: return UIImage(systemName: "airplane")
            case .education: return UIImage(systemName: "graduationcap")
            }
        }
        
    }
    
}

