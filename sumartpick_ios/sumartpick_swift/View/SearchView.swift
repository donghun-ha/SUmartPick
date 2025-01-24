//
//  SearchView.swift
//  SUmartPick
//
//  Created by aeong on 1/20/25.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            // 검색창
            HStack {
                TextField("검색어 입력", text: .constant(""))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                Image(systemName: "magnifyingglass")
                    .padding(.trailing)
            }
            .padding(.bottom)

            Spacer()
        }
    }
}
