//
//  SUmartPickApp.swift
//  SUmartPick
//
//  Created by aeong on 1/10/25.
//

import Firebase
import SwiftUI

@main
struct SUmartPickApp: App {
    @StateObject private var authState = AuthenticationState() // 인증 상태 객체 생성

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authState) // 환경 객체 주입
        }
    }
}
