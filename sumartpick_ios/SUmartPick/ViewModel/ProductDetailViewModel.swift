    //
    //  ProductDetailViewModel.swift
    //  SUmartPick
    //
    //  Created by 이종남 on 1/23/25.
    //
import Foundation

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchProductDetails(productID: Int) {
        isLoading = true
        errorMessage = nil

        // ✅ 정확한 API 엔드포인트로 수정
        guard let url = URL(string: "https://fastapi.sumartpick.shop/users/\(productID)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        // ✅ URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // ✅ GET 요청으로 변경
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ API 호출
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load product: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server error"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    // ✅ 응답 데이터를 Product 모델로 디코딩
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    self.product = try decoder.decode(Product.self, from: data)
                } catch {
                    self.errorMessage = "Failed to decode product: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
