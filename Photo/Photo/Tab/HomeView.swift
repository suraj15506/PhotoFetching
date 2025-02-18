//
//  HomeView.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//


import SwiftUI

struct HomeView: View {
    @StateObject var unsplashViewModel = UnsplashViewModel()
    

    var body: some View {
        
        func capitalizedURL(_ urlString: String) -> String {
           let urlComponents = urlString.split(separator: "/")
           if let first = urlComponents.first {
               return urlString.replacingOccurrences(of: String(first), with: first.capitalized)
           }
           return urlString
       }
        return NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                    ForEach(unsplashViewModel.images) { image in
                        NavigationLink(destination: ImageDetailView(image: image)) {
                            VStack {
                                AsyncImage(url: URL(string: capitalizedURL(image.urls.small))) { phase in
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
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensures the entire cell is tappable
                    }
                }
                .padding()
            }
            .navigationTitle("Unsplash Images")
            .onAppear {
                if unsplashViewModel.images.isEmpty {
                    unsplashViewModel.fetchImages()
                }
            }
        }
    }
    
    
    
}
