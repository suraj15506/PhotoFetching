//
//  FavoritesView.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @State private var isEditing = false

    let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

    var body: some View {
        NavigationView {
            VStack {
                if favoritesViewModel.favorites.isEmpty {
                    Text("No favorites yet!")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(favoritesViewModel.favorites) { image in
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(destination: ImageDetailView(image: image)) {
                                        VStack {
                                            AsyncImage(url: URL(string: image.urls.small)) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 150, height: 150)
                                                case .success(let img):
                                                    img
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 150, height: 150)
                                                        .cornerRadius(10)
                                                        .shadow(radius: 3)
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .frame(width: 150, height: 150)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            Text(image.user.name)
                                                .font(.caption).foregroundColor(.black)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    // "X" Button for Deleting in Edit Mode
                                    if isEditing {
                                        Button(action: {
                                            favoritesViewModel.removeFromFavorites(image: image)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.opacity(0.8))
                                                .clipShape(Circle())
                                        }
                                        .offset(x: -5, y: 5)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {  // Pull to Refresh
                        favoritesViewModel.loadFavorites()
                    }
                }
            }
            .onAppear {  // Load data instantly
                favoritesViewModel.loadFavorites()
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}
