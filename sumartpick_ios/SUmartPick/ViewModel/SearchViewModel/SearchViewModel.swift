///
///  SearchViewModel.swift
///  SUmartPick
///
///  Created by 하동훈 on 3/2/2025.
///
///  설명:
///  - 이 ViewModel은 상품 검색 기능을 관리합니다.
///  - FastAPI 백엔드에서 검색어에 맞는 상품 데이터를 가져옵니다.
///  - 검색 기록을 Realm 데이터베이스에 저장하고, 최근 검색어를 제공합니다.
///
///  주요 기능:
///  FastAPI에서 상품 검색 결과 가져오기 (`fetchSearchResults()`)
///  검색어를 Realm에 저장하여 최근 검색어 제공 (`saveSearchQuery()`)
///  최대 10개의 검색어만 저장하며 오래된 검색어 자동 삭제
///  전체 검색 기록 삭제 (`clearSearchHistory()`)
///
///  사용 방법:
///  - 사용자가 검색창에 입력하면 `fetchSearchResults()`를 호출하여 API에서 데이터를 가져옵니다.
///  - 검색어가 입력될 때마다 `saveSearchQuery()`를 호출하여 검색 기록을 유지합니다.
///  - 검색 기록은 `loadSearchHistory()`를 통해 불러올 수 있습니다.


import Foundation
import RealmSwift

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [SearchProduct] = [] // API에서 받아온 검색 결과
    @Published var searchHistory: [SearchHistory] = [] // Realm에서 불러온 검색 기록
    
    private let realm = try! Realm() // Realm 인스턴스
    private let baseURL = "https://fastapi.sumartpick.shop"
    
    init() {
        loadSearchHistory() // 초기화 시 검색 기록 로드
    }
    
    /// Realm에서 최근 검색어 불러오기
    func loadSearchHistory(){
        let history = realm.objects(SearchHistory.self)
            .sorted(byKeyPath: "timestamp", ascending: false) // 최신 검색어 먼저
        searchHistory = Array(history)
    }
    
    /// Realm에 검색어 저장 (최대 10개 유지)
    func saveSearchQuery(_ query: String){
        guard !query.isEmpty else {return}
        
        try! realm.write {
            // 중복된 검색어 제거
            if let existing = realm.objects(SearchHistory.self).filter("query == %@", query).first {
                realm.delete(existing)
            }
            
            // 새 검색어 추가
            let newHistory = SearchHistory()
            newHistory.query = query
            newHistory.timestamp = Date()
            realm.add(newHistory)
            
            // 최대 10개 초과 시 가장 오래된 항목 삭제
            let allHistory = realm.objects(SearchHistory.self).sorted(byKeyPath: "timestamp", ascending: false)
            if allHistory.count > 10 {
                realm.delete(allHistory.self)
            }
        }
        loadSearchHistory() // UI 업데이트
    }
    
    /// 검색 기록 전체 삭제
    func clearSearchHistory() {
        try! realm.write {
            realm.delete(realm.objects(SearchHistory.self))
        }
        searchHistory.removeAll()
    }
    
    /// API 검색 기능
    func fetchSearchResults() async {
        guard !searchQuery.isEmpty else {return}
        guard let url = URL(string: "\(baseURL)/products_query") else {return}
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = ["name": searchQuery]
            request.httpBody = try! JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try! await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("검색 API 오류: \(httpResponse.statusCode)")
                return
            }
            
            let decodedResponse = try! JSONDecoder().decode([SearchProduct].self, from: data)
            searchResults = decodedResponse
            
            saveSearchQuery(searchQuery) // 검색어 저장
        }
    }
}
