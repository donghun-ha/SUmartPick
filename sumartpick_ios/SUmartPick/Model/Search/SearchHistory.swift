//
//  SearchHistory.swift
//  SUmartPick
//
//  Created by 하동훈 on 3/2/2025.
//

import RealmSwift
import Foundation

// Realm에 저장될 검색 기록 모델
class SearchHistory: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId // 고유 ID
    @Persisted var query: String // 검색어
    @Persisted var timestamp: Date // 검색 시간
}
