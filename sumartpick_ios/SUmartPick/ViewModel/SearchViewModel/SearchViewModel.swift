///
///  SearchViewModel.swift
///  SUmartPick
///
///  Created by 하동훈 on 3/2/2025.
///
///  Description:


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
