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

// API 응답을 올바르게 매핑하기 위한 구조체
struct ProductResponse: Codable {
    let results: [Product] // "results" 키를 매핑하여 상품 배열을 가져옴
}

@MainActor
class HomeViewModel: ObservableObject {
    @Published var products: [Product] = [] // 홈 화면에 표시할 상품 목록
    @Published var searchResults: [Product] = [] // 검색 결과 목록
    private let baseURL = "https://fastapi.sumartpick.shop" // API 기본 URL
    
    init() {
        Task {
            await fetchHomeProducts() // 뷰모델 초기화 시 API 호출
        }
    }
    
    /// 홈 화면에 표시할 상품 목록을 불러오는 함수
    /// - API: `/get_all_products`
    /// - 최대 10개의 상품을 가져와 `products`에 저장
    func fetchHomeProducts() async {
        guard let url = URL(string: "\(baseURL)/get_all_products") else {
            print("❌ URL 생성 실패")
            return
        }
        
        do {
            let decodedResponse: ProductResponse = try await requestData(from: url)
            products = Array(decodedResponse.results.prefix(10)) // 10개만 저장
            print("✅ 상품 목록 로드 성공: \(products.count)개")
        } catch {
            print("❌ 상품 목록 로딩 실패: \(error)")
        }
    }
    
    /// 검색 기능을 수행하는 함수
    /// - Parameter query: 검색할 상품의 키워드
    /// - API: `/search_products?name={query}`
    /// - 검색 결과를 `searchResults`에 저장
    func fetchSearchResults(query: String) async {
        guard let url = URL(string: "\(baseURL)/search_products?name=\(query)") else {
            print("❌ 검색 URL 생성 실패")
            return
        }
        
        do {
            let decodedResponse: ProductResponse = try await requestData(from: url)
            searchResults = decodedResponse.results
            print("✅ 검색 성공: \(searchResults.count)개 결과")
        } catch {
            print("❌ 검색 실패: \(error)")
        }
    }
    
    // 특정 카테고리에 해당하는 상품을 불러오는 함수
    // - Parameters categoryID: 선택한 카테고리의 ID
    // - API: 'get_products_by_category?category_id={category_id}
    func fetchProductsByCategory(categoryID: Int) async {
        guard let url = URL(string: "\(baseURL)/get_products_by_category?category_id=\(categoryID)") else {
            print("카테고리 URL 생성 실패")
            return
        }
        
        do {
            let decodedResponse: ProductResponse = try await requestData(from: url)
            products = decodedResponse.results // 해당 카테고리의 상품만 업데이트
            print("카테고리 ID\(categoryID) 로드 성공")
        } catch {
            print("카테고리 매핑 상품 로드 실패")
        }
    }
    
    /// 공통 API 요청 및 JSON 디코딩 함수 (`async/await` 적용)
    /// - Parameter url: 요청할 API의 URL
    /// - Returns: 디코딩된 `ProductResponse`
    private func requestData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("ℹ️ 서버 응답 코드: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
