//
//  HomeView.swift
//  SUmartPick
//
//  Created by aeong on 1/20/25.
//

import SwiftUI

struct HomeView: View {
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

                // 추천 상품
                Spacer()
                Text("추천 상품")
                    .font(.headline)
                    .padding(.bottom)

                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
