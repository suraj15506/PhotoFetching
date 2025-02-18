//
//  UnsplashViewModel.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//


import Foundation

class UnsplashViewModel: ObservableObject {
    @Published var images: [UnsplashImage] = []
    @Published var isLoading = false  // Prevent duplicate requests
    private var currentPage = 1
    private let perPage = 100  // Fetch more images per request

    private var apiKey: String {
        return "0iQ3eOUgf2YHSRqqIdPbvBlfPVZSVae4rqmhaSqOpjA"
    }

    func fetchImages(query: String? = nil, isNewSearch: Bool = false) {
        guard !isLoading else { return }
        isLoading = true

        if isNewSearch {
            currentPage = 1
            images.removeAll() // Clear previous images
        }

        let urls: [URL] = (0..<2).compactMap { offset in  // Fetch 2 pages in parallel
            let page = currentPage + offset
            let urlString: String
            if let query = query, !query.isEmpty {
                urlString = "https://api.unsplash.com/search/photos?query=\(query)&page=\(page)&per_page=\(perPage)&order_by=latest&client_id=\(apiKey)"
            } else {
                urlString = "https://api.unsplash.com/photos?page=\(page)&per_page=\(perPage)&order_by=latest&client_id=\(apiKey)"
            }
            return URL(string: urlString)
        }

        let group = DispatchGroup()

        for url in urls {
            group.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                DispatchQueue.main.async {
                    if let query = query, !query.isEmpty {
                        if let decodedResponse = try? JSONDecoder().decode(SearchResponse.self, from: data) {
                            self.addUniqueImages(decodedResponse.results)
                        } else {
                            print("Failed to decode search response")
                        }
                    } else {
                        if let decodedResponse = try? JSONDecoder().decode([UnsplashImage].self, from: data) {
                            self.addUniqueImages(decodedResponse)
                        } else {
                            print("Failed to decode photo response")
                        }
                    }
                }
            }.resume()
        }

        group.notify(queue: .main) {
            self.isLoading = false
            self.currentPage += 2  // Move to the next 2 pages
        }
    }

    private func addUniqueImages(_ newImages: [UnsplashImage]) {
        let uniqueImages = newImages.filter { newImage in
            !self.images.contains(where: { $0.id == newImage.id })
        }
        self.images.append(contentsOf: uniqueImages)
    }
}
