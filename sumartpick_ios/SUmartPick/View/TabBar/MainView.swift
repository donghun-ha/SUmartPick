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
            MyPageView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("마이페이지")
                }

            // 장바구니 화면
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("장바구니")
                }
        }
    }
}
