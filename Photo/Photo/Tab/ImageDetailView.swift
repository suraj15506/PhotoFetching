//
//  ImageDetailView.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//

//import SwiftUI
//
//struct ImageDetailView: View {
//    let image: UnsplashImage
//
//    var body: some View {
//        VStack {
//            // Image
//            AsyncImage(url: URL(string: image.urls.regular)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()  // Show a loading indicator while the image is loading
//                        .frame(width: 300, height: 300)
//                case .success(let img):
//                    img
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 300)
//                        .cornerRadius(10)
//                case .failure:
//                    Image(systemName: "exclamationmark.triangle.fill")  // Error icon
//                        .frame(width: 300, height: 300)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//
//            // Description (use a default text if description is nil)
//            Text(image.description ?? "No Description Available")
//                .font(.headline)
//                .padding(.top, 8)
//                .multilineTextAlignment(.center)  // Center the text for better readability
//
//            // Photographer's name
//            Text("By \(image.user.name)")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .padding(.top, 4)
//        }
//        .padding()
//        .navigationTitle("Details")
//    }
//}


import SwiftUI

struct ImageDetailView: View {
    let image: UnsplashImage
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel

    var isFavorited: Bool {
        favoritesViewModel.favorites.contains(where: { $0.id == image.id })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image Display
                AsyncImage(url: URL(string: image.urls.regular)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 350, height: 350)
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    case .failure:
                        Image(systemName: "photo.on.rectangle.angled")
                            .frame(width: 350, height: 350)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)

                // Favorite & Share Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if isFavorited {
                            favoritesViewModel.removeFromFavorites(image: image)
                        } else {
                            favoritesViewModel.addToFavorites(image: image)
                        }
                    }) {
                        Label("Favorite", systemImage: isFavorited ? "heart.fill" : "heart")
                            .padding()
                            .background(isFavorited ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .foregroundColor(isFavorited ? .red : .primary)

                    Button(action: {
                        downloadAndShareImage()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical)

                // Image Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(image.description ?? image.alt_description ?? "No Description Available")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.leading)

                    Text("By **\(capitalizedURL(image.user.name))**")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if let portfolio = image.user.portfolio_url {
                        Link("View Profile", destination: URL(string: portfolio)!)
                            .foregroundColor(.blue)
                    }

                    Text("📅 Uploaded on: \(formatDate(image.created_at))")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Text("📏 Size: \(image.width) × \(image.height) pixels")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Photo Details")
    }

    // MARK: - Helper Functions
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return "Unknown Date"
    }

    private func downloadAndShareImage() {
        guard let url = URL(string: image.urls.regular) else { return }

        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {

                let temporaryDirectory = FileManager.default.temporaryDirectory
                let fileURL = temporaryDirectory.appendingPathComponent("shared_image.jpg")

                do {
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
    func capitalizedURL(_ urlString: String) -> String {
       let urlComponents = urlString.split(separator: "/")
       if let first = urlComponents.first {
           return urlString.replacingOccurrences(of: String(first), with: first.capitalized)
       }
       return urlString
   }
}
