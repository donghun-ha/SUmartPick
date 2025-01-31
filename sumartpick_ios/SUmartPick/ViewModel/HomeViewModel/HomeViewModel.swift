///
///  HomeViewModel.swift
///  SUmartPick
///
///  Created by 하동훈 on 23/1/2025.
///
///  Description:
///  - 홈 화면의 데이터를 관리하는 ViewModel 입니다.
///  - 상품 목록을 불러오는 API와 검색 기능을 담당합니다.
///  - `fetchHomeProducts()`를 사용해 홈 화면에서 10개의 상품을 로드합니다.
///  - `fetchSearchResults(query:)`를 사용해 검색 결과를 업데이트합니다.
///

import SwiftUI

// API 응답을 올바르게 매핑하기 위한 구조체 추가
struct ProductResponse: Codable {
    let results: [Product] // "results" 키를 매핑하여 상품 배열을 가져옴
}

class HomeViewModel: ObservableObject {
    @Published var products: [Product] = [] // 홈 화면에 표시할 상품 목록
    @Published var searchResults: [Product] = [] // 검색 결과 목록
    private let baseURL = "https://fastapi.sumartpick.shop" // API 기본 URL
    
    init() {
        fetchHomeProducts() // 뷰모델 초기화 시 API 호출
    }
    
    /// 홈 화면에 표시할 상품 목록을 불러오는 함수
    /// - API: `/product_select_all`
    /// - 최대 10개의 상품을 가져와 `products`에 저장
    func fetchHomeProducts() {
        guard let url = URL(string: "\(baseURL)/product_select_all") else {
            print("❌ URL 생성 실패")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    // ProductResponse로 디코딩하여 "results" 키의 배열을 가져옴
                    let decodedResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.products = Array(decodedResponse.results.prefix(10)) // 10개만 저장
                        print("✅ 상품 목록 로드 성공: \(self.products.count)개")
                    }
                } catch {
                    print("❌ JSON 디코딩 실패: \(error)")
                }
            }
        }.resume()
    }
    
    /// 검색 기능을 수행하는 함수
    /// - Parameter query: 검색할 상품의 키워드
    /// - API: `/products_query?name={query}`
    /// - 검색 결과를 `searchResults`에 저장
    func fetchSearchResults(query: String) {
        guard let url = URL(string: "\(baseURL)/products_query?name=\(query)") else {
            print("❌ 검색 URL 생성 실패")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 검색 요청 실패: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.searchResults = decodedResponse.results // 검색 결과 업데이트
                        print("✅ 검색 성공: \(self.searchResults.count)개 결과")
                    }
                } catch {
                    print("❌ 검색 JSON 디코딩 실패: \(error)")
                }
            }
        }.resume()
    }
}
