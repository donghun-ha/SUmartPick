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

        let url = URL(string: "https://sumartpick.shop")!   // Fastapi 주소로 변경
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                    self.product = try decoder.decode(Product.self, from: data)
                } catch {
                    self.errorMessage = "Failed to decode product: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
