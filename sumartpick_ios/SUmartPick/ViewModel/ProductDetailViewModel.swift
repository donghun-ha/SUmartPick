    //
    //  ProductDetailViewModel.swift
    //  SUmartPick
    //
    //  Created by 이종남 on 1/23/25.
    //
import Foundation

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var reviews: [ReviewItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchProductDetails(productID: Int) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://fastapi.sumartpick.shop/get_product/\(productID)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load product: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let resultData = jsonObject["result"] {
                        let resultJSON = try JSONSerialization.data(withJSONObject: resultData)
                        self.product = try decoder.decode(Product.self, from: resultJSON)
                        
                        self.fetchReviews(productID: productID) // ✅ 리뷰 데이터 불러오기
                    }
                } catch {
                    self.errorMessage = "Failed to decode product: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // ✅ 리뷰 API 호출 및 디코딩 오류 수정
    func fetchReviews(productID: Int) {
        guard let url = URL(string: "https://fastapi.sumartpick.shop/get_reviews/\(productID)") else {
            print("Invalid Review URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load reviews: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No review data received")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    
                    // ✅ JSON 최상위 키를 맞춰서 디코딩
                    let response = try decoder.decode([String: [ReviewItem]].self, from: data)
                    self.reviews = response["reviews"] ?? []

                    print("✅ Reviews Decoded: \(self.reviews.count)개")

                } catch {
                    print("❌ Failed to decode reviews: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
