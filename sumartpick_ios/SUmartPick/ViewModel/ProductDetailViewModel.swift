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

        // FastAPI의 엔드포인트 URL (상품 상세 정보 조회 API)
        guard let url = URL(string: "https://sumartpick.shop/products_query") else {
            self.isLoading = false
            self.errorMessage = "Invalid URL"
            return
        }

        // 요청 데이터 생성
        let requestData: [String: Any] = ["name": "\(productID)"]

        do {
            // 요청 데이터를 JSON 형식으로 변환
            let requestDataBody = try JSONSerialization.data(withJSONObject: requestData, options: [])

            // URLRequest 생성
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestDataBody

            // URLSession으로 API 호출
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
                        // 응답 데이터를 디코딩
                        let decoder = JSONDecoder()
                        let products = try decoder.decode([Product].self, from: data)

                        // ProductID에 해당하는 상품만 필터링
                        self.product = products.first(where: { $0.productID == productID })

                        if self.product == nil {
                            self.errorMessage = "Product not found"
                        }
                    } catch {
                        self.errorMessage = "Failed to decode product: \(error.localizedDescription)"
                    }
                }
            }.resume()

        } catch {
            self.isLoading = false
            self.errorMessage = "Failed to create request body: \(error.localizedDescription)"
        }
    }
}
