//
//  UnsplashImage.swift
//  Photo
//
//  Created by Suraj Singh on 17/02/25.
//

import Foundation

struct SearchResponse: Codable {
    let results: [UnsplashImage]
}

struct UnsplashImage: Identifiable, Codable {
    let id: String
    let description: String?
    let alt_description: String?
    let created_at: String
    let width: Int
    let height: Int
    let likes: Int
    let user: UnsplashUser
    let exif: ExifData?
    let location: PhotoLocation?
    let urls: ImageURLs
}

struct UnsplashUser: Codable {
    let name: String
    let bio: String?
    let portfolio_url: String?
}

struct ImageURLs: Codable {
    let regular: String
    let small: String
}

struct ExifData: Codable {
    let make: String?
    let model: String?
    let exposure_time: String?
    let aperture: String?
    let focal_length: String?
    let iso: Int?
}

struct PhotoLocation: Codable {
    let name: String?
    let city: String?
    let country: String?
}
