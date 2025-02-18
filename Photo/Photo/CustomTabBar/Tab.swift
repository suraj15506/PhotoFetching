//
//  Tab.swift
//  Shelves-User
//
//  Created by Suraj Raj on 06/07/24.
//

import Foundation

enum Tab: String, CaseIterable
{
    case home = "Home"
    case search = "Search"
    case favorites = "Favorites"
    case profile = "Profile"
    
    var systemImage: String
    {
        switch self{
        case .search:
            return "magnifyingglass"
            
        case .favorites:
            return "heart"
            
        case .home:
            
            return "house"
            
            
        case .profile:
            return "person"
        }
    }
    var index: Int{
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}
