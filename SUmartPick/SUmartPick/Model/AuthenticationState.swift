//
//  AuthenticationState.swift
//  SUmartPick
//
//  Created by aeong on 1/13/25.
//

import Combine
import SwiftUI

class AuthenticationState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userIdentifier: String? = nil
}
