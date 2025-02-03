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
        (id: 4, name: "가구", icon: "bed.double"),
        (id: 6, name: "도서", icon: "book"),
        (id: 7, name: "미디어", icon: "tv"),
        (id: 8, name: "뷰티", icon: "paintbrush"),
        (id: 9, name: "스포츠", icon: "sportscourt"),
        (id: 10, name: "식품", icon: "cart"),
        (id: 11, name: "유아/애완", icon: "pawprint"),
        (id: 12, name: "전자제품", icon: "desktopcomputer"),
        (id: 13, name: "패션", icon: "tshirt"),
        (id: 5, name: "기타", icon: "ellipsis")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) { // 전체 VStack 왼쪽 정렬
                    headerView
                    searchView
                    CategoryGridView(categories: categories, viewModel: viewModel)

                    // 섹션 구분을 위한 Divider 추가
                    Divider()
                        .padding(.vertical, 10)

                    Text("🛒 이 상품을 놓치지 마세요!")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                        .padding(.leading, 10) // 좌측 여백 추가

                    ProductGridView(
                        products: viewModel.products,
                        selectedProductID: $selectedProductID,
                        isNavigatingToDetail: $isNavigatingToDetail
                    )

                    Spacer()
                        .frame(height: 50) // 하단 공간 확보 (탭바와 겹치지 않도록)
                }
                .padding(.horizontal)
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
        let categories: [(id: Int ,name: String, icon: String)] // (카테고리명, 아이콘)
        @ObservedObject var viewModel: HomeViewModel

        var body: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                ForEach(categories, id: \.id) { category in
                    VStack {
                        Image(systemName: category.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text(category.name)
                            .font(.caption)
                    }
                    .onTapGesture {
                        Task {
                            await viewModel.fetchProductsByCategory(categoryID: category.id)
                        }
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
                    VStack(alignment: .leading) { // 🔹 왼쪽 정렬
                        AsyncImage(url: URL(string: product.previewImage)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)

                        Text(product.name)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                            .padding(.leading, 5) // 패딩 추가

                        Text("\(Int(product.price)) 원")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                            .padding(.leading, 5) // 패딩 추가
                    }
                    .onTapGesture {
                        selectedProductID = product.productID
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
                Task {
                    await viewModel.fetchSearchResults(query: searchText)
                }
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
}
