//
//  SearchView.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = UnsplashViewModel()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var recentSearches: [String] = UserDefaults.standard.stringArray(forKey: "RecentSearches") ?? [] // Load saved searches
    
    private let maxRecentSearches = 5  // Limit recent searches to 5
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search images...", text: $searchText, onEditingChanged: { editing in
                        isSearching = editing
                    })
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    isSearching = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    )
                    .onSubmit {
                        performSearch()
                    }
                    
                    Button(action: {
                        performSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                
                // Recent Searches
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .padding(.leading, 16)
                            
                            Spacer()
                            
                            Button("Clear") {
                                clearRecentSearches()
                            }
                            .foregroundColor(.red)
                            .padding(.trailing, 16)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(recentSearches, id: \.self) { recent in
                                    Text(recent)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(15)
                                        .onTapGesture {
                                            searchText = recent
                                            performSearch()
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Image Grid View
                ScrollView {
                    if viewModel.isLoading && viewModel.images.isEmpty {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
                            ForEach(viewModel.images) { image in
                                NavigationLink(destination: ImageDetailView(image: image)) {
                                    AsyncImage(url: URL(string: image.urls.small)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 160, height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            ProgressView()
                                                .frame(width: 160, height: 160)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .refreshable {
                    viewModel.fetchImages(query: searchText, isNewSearch: true)
                }
            }
            .navigationTitle("Search")
        }
    }

    // Perform Search and Store in Recent Searches
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        viewModel.fetchImages(query: searchText, isNewSearch: true)
        isSearching = false
        addRecentSearch(searchText)
    }
    
    // Add Search Term to Recent Searches
    private func addRecentSearch(_ query: String) {
        if !recentSearches.contains(query) {
            recentSearches.insert(query, at: 0)
            if recentSearches.count > maxRecentSearches {
                recentSearches.removeLast()
            }
            saveRecentSearches()
        }
    }

    // Save Recent Searches to UserDefaults
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "RecentSearches")
    }

    // Clear Recent Searches
    private func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: "RecentSearches")
    }
}
