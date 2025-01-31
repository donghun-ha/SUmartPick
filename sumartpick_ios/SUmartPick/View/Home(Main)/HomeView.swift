///
///  HomeView.swift
///  SUmartPick
///
///  Created by 하동훈 on 1/23/25.
///
///  Description:
///  - 홈 화면을 구성하는 SwiftUI 뷰입니다.
///  - 카테고리 목록을 2줄 5컬럼의 `LazyVGrid`로 표시합니다.
///  - 검색 기능을 제공하며, 검색어 입력 시 `fetchSearchResults(query:)`를 호출합니다.
///  - "이 상품을 놓치지 마세요!" 섹션에서 최대 10개의 추천 상품을 표시합니다.
///  - 하단에는 스크롤 맨 위로 이동할 수 있는 버튼이 포함되어 있습니다.
///

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedProductID: Int? = nil
    @State private var isNavigatingToDetail = false
    @State private var searchText: String = ""
    
    let categories = [
        "가구", "도서", "미디어", "뷰티", "스포츠",
        "식품", "유아/애완", "전자제품", "패션", "기타"
    ]
    let categoryIcons = [
        "bed.double", "book", "tv", "paintbrush", "sportscourt",
        "cart", "pawprint", "desktopcomputer", "tshirt", "ellipsis"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    headerView
                    searchView
                    CategoryGridView(categories: Array(zip(categories, categoryIcons)))
                    Text("🛒 이 상품을 놓치지 마세요!")
                        .font(.headline)
                        .padding(.top, 10)
                    ProductGridView(products: viewModel.products, selectedProductID: $selectedProductID, isNavigatingToDetail: $isNavigatingToDetail)
                    topButton
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $isNavigatingToDetail) {
                if let productID = selectedProductID {
                    DetailView(productID: productID)
                }
            }
        }
    }
    
    /// 카테고리 그리드 뷰
    struct CategoryGridView: View {
        let categories: [(String, String)] // (카테고리명, 아이콘)

        var body: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                ForEach(categories, id: \.0) { category, icon in
                    VStack {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text(category)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    /// 상품 그리드 뷰
    struct ProductGridView: View {
        let products: [Product] // 상품 배열
        @Binding var selectedProductID: Int?
        @Binding var isNavigatingToDetail: Bool

        var body: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                ForEach(products) { product in
                    VStack {
                        AsyncImage(url: URL(string: product.preview_image)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        Text(product.name)
                            .font(.caption)
                        Text("₩\(Int(product.price))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        selectedProductID = product.Product_ID
                        isNavigatingToDetail = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("SUmartPick")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
            Spacer()
            Image(systemName: "cart")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.trailing)
        }
        .padding(.top)
    }
    
    private var searchView: some View {
        HStack {
            TextField("상품 검색", text: $searchText, onCommit: {
                viewModel.fetchSearchResults(query: searchText)
            })
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            Image(systemName: "magnifyingglass")
                .padding(.trailing)
        }
        .padding(.bottom)
    }

    private var topButton: some View {
        Button(action: {
            withAnimation {
                UIScrollView.appearance().scrollsToTop = true
            }
        }) {
            Image(systemName: "arrow.up")
                .padding()
                .background(Color.blue.opacity(0.8))
                .clipShape(Circle())
                .foregroundColor(.white)
        }
        .padding(.top, 20)
    }
}
