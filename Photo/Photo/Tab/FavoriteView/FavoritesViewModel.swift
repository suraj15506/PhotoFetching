//
//  FavoritesViewModel.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//

import SwiftUI

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [UnsplashImage] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let favoritesKey = "favoriteImages"
    
    init() {
        loadFavorites()
    }
    
    func addToFavorites(image: UnsplashImage) {
        if !favorites.contains(where: { $0.id == image.id }) {
            favorites.append(image)
        }
    }
    
    func removeFromFavorites(image: UnsplashImage) {
        favorites.removeAll { $0.id == image.id }
    }
    
    // MARK: - Data Persistence
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func loadFavorites() {
        DispatchQueue.main.async {  // Ensures fast UI update
            if let savedData = UserDefaults.standard.data(forKey: self.favoritesKey),
               let decodedFavorites = try? JSONDecoder().decode([UnsplashImage].self, from: savedData) {
                self.favorites = decodedFavorites
            }
        }
    }
}
