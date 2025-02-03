//
//  **Config.swift
//  SUmartPick
//
//  Created by aeong on 1/21/25.
//

enum AppEnvironment {
    case local
    case remote
    case server
}

enum SUmartPickConfig {
    static let dbenvironment: AppEnvironment = .server

    static var baseURL: String {
        switch dbenvironment {
            case .local:
                return "http://127.0.0.1:8000"
            case .remote:
                return "http://192.168.50.71:8000"
            case .server:
                return "https://fastapi.sumartpick.shop"
        }
    }
}
