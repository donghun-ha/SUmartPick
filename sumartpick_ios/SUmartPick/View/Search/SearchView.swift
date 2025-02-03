///  SearchView.swift
///  SUmartPick
///
///  Created by 하동훈 on 3/2/2025.
///
///  설명:
///  - 이 View는 상품 검색 UI를 담당합니다.
///  - 사용자가 검색어를 입력하면 FastAPI에서 데이터를 가져옵니다.
///  - 검색어 입력 시 실시간으로 검색 결과를 표시합니다.
///  - 최근 검색어 목록을 제공하며, 특정 검색어를 선택하면 자동 검색이 실행됩니다.
///  - 검색창을 지우면 검색 결과가 함께 사라집니다.
///
///  주요 기능:
///  - 검색 입력 필드 (`TextField`)에 검색어 입력 및 돋보기 아이콘 추가
///  - 검색어가 변경될 때마다 `searchResults` 업데이트 (`onChange` 사용)
///  - 최근 검색어를 버튼 형태로 제공하여 빠른 검색 가능
///  - 검색 결과를 카드 형태(`ProductCardView`)로 표시
///  - 최근 검색어 전체 삭제 기능 (`clearSearchHistory()`)
///
///  사용 방법:
///  - 검색어를 입력하면 자동으로 API에서 데이터를 불러옵니다.
///  - 최근 검색어를 탭하면 해당 검색어로 즉시 검색됩니다.
///  - X 버튼을 눌러 검색어를 지우면 검색 결과도 함께 삭제됩니다.
///

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // 검색창 (둥글게 + 돋보기 추가)
                HStack {
                    TextField("상품 검색", text: $viewModel.searchQuery, onCommit: {
                        Task { await viewModel.fetchSearchResults() }
                    })
                    .onChange(of: viewModel.searchQuery) { _, value in
                        if value.isEmpty {
                            viewModel.searchResults.removeAll()
                        }
                    }
                    .padding(.horizontal, 40) // 아이콘 간격 확보
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20) // 둥글게 설정
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            Spacer()
                        }
                    )
                }
                .padding()

                // 최근 검색어 표시
                if !viewModel.searchHistory.isEmpty {
                    VStack {
                        HStack {
                            Text("최근 검색어")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                viewModel.clearSearchHistory()
                            }) {
                                Text("전체 삭제")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    
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
                
                // 검색 결과 (카드형 UI)
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.searchResults, id: \.id) { product in
                            ProductCardView(product: product) // 카드형 UI 적용
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("상품 검색")
        }
    }
}
