//
//  ReviewsViewModel.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

//
//  ReviewsViewModel.swift
//  SUmartPick
//
//  Created by aeong on 1/23/25.
//

import SwiftUI

@MainActor
class ReviewsViewModel: ObservableObject {
    @Published var reviews: [ReviewItem] = []
    @Published var errorMessage: String = ""
    @Published var showErrorAlert = false

    let baseURL = SUmartPickConfig.baseURL

    func fetchReviews(for userID: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/\(userID)") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let rawJSON = String(data: data, encoding: .utf8) {
                print("리뷰 목록 JSON:\n\(rawJSON)")
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            let fetchedReviews = try decoder.decode([ReviewItem].self, from: data)
            self.reviews = fetchedReviews
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    func addReview(userID: String, productID: Int, content: String, star: Int) async {
        guard let url = URL(string: "\(baseURL)/reviews") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "User_ID": userID,
            "Product_ID": productID,
            "Review_Content": content,
            "Star": star
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }
            // 성공 후 다시 리뷰 목록 갱신
            await self.fetchReviews(for: userID)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    // (A) 리뷰 수정
    func updateReview(reviewID: Int, newContent: String, star: Int, userID: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "Review_Content": newContent,
            "Star": star
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }
            // 수정 성공 후 다시 리뷰 목록 갱신
            await self.fetchReviews(for: userID)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    // (B) 리뷰 삭제
    func deleteReview(reviewID: Int, userID: String) async {
        guard let url = URL(string: "\(baseURL)/reviews/\(reviewID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw URLError(.badServerResponse)
            }
            // 삭제 성공 후 다시 리뷰 목록 갱신
            await self.fetchReviews(for: userID)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
}
