//
//  ReviewWriteView.swift
//  SUmartPick
//
//  Created by aeong on 2/5/25.
//

import SwiftUI

/// 리뷰 작성 화면 (Delivered 상태의 주문에 대해 리뷰를 작성)
struct ReviewWriteView: View {
    // 리뷰 작성을 위해 선택된 주문 정보
    let order: OrderItem
    // 환경 객체에서 인증 정보를 가져옴 (사용자 ID 등)
    @EnvironmentObject var authState: AuthenticationState
    // 화면 dismiss를 위한 환경 변수
    @Environment(\.dismiss) var dismiss

    // 리뷰 내용과 별점 입력을 위한 State
    @State private var reviewContent: String = ""
    @State private var starRating: Int = 5

    // 네트워크 요청 상태 관리
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var showSuccessAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // 주문 정보 표시 (상품명, 가격 등)
                Section(header: Text("상품 정보")) {
                    Text("상품명: \(order.productName)")
                    Text("가격: \(Int(order.productPrice))원")
                }

                // 리뷰 내용 입력
                Section(header: Text("리뷰 내용")) {
                    TextEditor(text: $reviewContent)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // 별점 입력 (Stepper 사용)
                Section(header: Text("별점")) {
                    Stepper("별점: \(starRating)", value: $starRating, in: 1 ... 5)
                }

                // 리뷰 제출 버튼
                Section {
                    Button(action: {
                        Task {
                            await submitReview()
                        }
                    }) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text("리뷰 작성")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .disabled(reviewContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                }
            }
            .navigationTitle("리뷰 작성")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            // 에러 Alert
            .alert("리뷰 작성 실패", isPresented: $showErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            // 성공 Alert
            .alert("리뷰 작성 성공", isPresented: $showSuccessAlert) {
                Button("확인") { dismiss() }
            } message: {
                Text("리뷰가 성공적으로 등록되었습니다.")
            }
        }
    }

    /// 리뷰 작성 API를 호출하는 함수
    private func submitReview() async {
        guard let userID = authState.userIdentifier else {
            errorMessage = "사용자 정보가 없습니다."
            showErrorAlert = true
            return
        }
        isSubmitting = true

        // 리뷰 작성 API에 보낼 데이터 생성
        let reviewDict: [String: Any] = [
            "User_ID": userID,
            "Product_ID": order.productId,
            "Review_Content": reviewContent,
            "Star": starRating
        ]

        guard let url = URL(string: "\(SUmartPickConfig.baseURL)/reviews") else {
            errorMessage = "잘못된 URL입니다."
            showErrorAlert = true
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: reviewDict)
        } catch {
            errorMessage = "리뷰 데이터를 직렬화하는 데 실패했습니다."
            showErrorAlert = true
            isSubmitting = false
            return
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "서버 응답 오류 (상태 코드: \(statusCode))"
                showErrorAlert = true
                isSubmitting = false
                return
            }
            // 성공 시 성공 Alert 표시
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        isSubmitting = false
    }
}
