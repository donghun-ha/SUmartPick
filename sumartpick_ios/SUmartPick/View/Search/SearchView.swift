///
///  SearchView.swift
///  SUmartPick
///
///  Created by 하동훈 2/3/25.
///

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // 🔹 검색창
                TextField("상품 검색", text: $viewModel.searchQuery, onCommit: {
                    Task { await viewModel.fetchSearchResults() }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                // 🔹 최근 검색어 표시
                if !viewModel.searchHistory.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.searchHistory, id: \.id) { history in
                                Button(action: {
                                    viewModel.searchQuery = history.query
                                    Task { await viewModel.fetchSearchResults() }
                                }) {
                                    Text(history.query)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                
                // 🔹 검색 결과 표시
                List(viewModel.searchResults, id: \.Product_ID) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text("\(product.price)원")
                            .foregroundColor(.gray)
                    }
                }
                
                // 🔹 검색 기록 전체 삭제 버튼
                Button("검색 기록 삭제") {
                    viewModel.clearSearchHistory()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("상품 검색")
        }
    }
}
