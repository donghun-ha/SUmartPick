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
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    return
                }

                print("📡 Status Code: \(httpResponse.statusCode)")

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Response Data: \(jsonString)")
                }

                do {
                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let resultData = jsonObject["result"] {
                        
                        let resultJSON = try JSONSerialization.data(withJSONObject: resultData)
                        self.product = try decoder.decode(Product.self, from: resultJSON)

                    } else {
                        self.errorMessage = "Invalid response format"
                    }

                } catch {
                    self.errorMessage = "Failed to decode product: \(error.localizedDescription)"
                    print("❗️Decoding Error: \(error)")
                }
            }
        }.resume()
    }
}
