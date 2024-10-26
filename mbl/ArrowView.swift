//
//  ArrowView.swift
//  mbl
//
//  Created on 10/26/24.
//
import SwiftUI

struct ArrowView: View {
    var angle: Double
    var size: CGFloat = 20 // 기본 크기 설정

    var body: some View {
        Image(systemName: "arrow.up")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size) // 텍스트와 같은 크기로 설정
            .rotationEffect(.degrees(angle)) // 방위각에 따라 회전
            .foregroundColor(.blue) // 화살표 색상
    }
}
