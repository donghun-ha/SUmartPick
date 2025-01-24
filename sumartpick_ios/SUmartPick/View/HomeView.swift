//
//  HomeView.swift
//  SUmartPick
//
//  Created by aeong on 1/20/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedProductID: Int? = nil
    @State private var isNavigatingToDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                // 상단 타이틀
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

                // 검색창
                HStack {
                    TextField("상품 검색", text: .constant(""))
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing)
                }
                .padding(.bottom)

                // 버튼 추가
                Button(action: {
                    selectedProductID = 1 // 예: productID 1 설정
                    isNavigatingToDetail = true
                }) {
                    Text("DetailView로 이동")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                // 추천 상품
                Spacer()
                Text("추천 상품")
                    .font(.headline)
                    .padding(.bottom)
                    // NavigationLink를 통해 DetailView로 이동
                    .navigationDestination(isPresented: $isNavigatingToDetail) {
                        DetailView(productID: selectedProductID ?? 1)
                    }
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}
