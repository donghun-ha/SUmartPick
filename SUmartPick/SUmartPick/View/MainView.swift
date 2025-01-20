//
//  MainView.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authState: AuthenticationState // 인증 상태 공유 객체

    var body: some View {
        TabView {
            // 홈 화면
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }

            // 검색 화면
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("검색")
                }

            // 마이페이지 화면
            Text("마이페이지")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이페이지")
                }

            // 장바구니 화면
            Text("장바구니")
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("장바구니")
                }
        }
    }
}

// 홈 화면 구성
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

// 검색 화면 구성
struct SearchView: View {
    var body: some View {
        Text("검색 화면")
    }
}
