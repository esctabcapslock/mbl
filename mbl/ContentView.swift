//
//  ContentView.swift
//  mbl
//
//  Created on 10/26/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Text("Food Menu")
                .font(.title)
                .padding()

            ScrollView {
                Text(networkManager.foodMenu)
                .padding()
                .foregroundColor(.black) // HTML 태그가 포함된 경우 스타일링
            }
            
            if let location = locationManager.location {
                Text("위도: \(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
                    .padding()
            } else {
                Text("위치 정보를 가져오는 중...")
                    .padding()
            }
        }
        .onAppear {
            print("test print")
            locationManager.startUpdatingLocation() // 수정된 부분
            networkManager.fetchFoodMenu()

        }

    }
}
