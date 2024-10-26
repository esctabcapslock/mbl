//
//  ContentView.swift
//  mbl
//
//  Created on 10/26/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantInfoManager = RestaurantInfoManager()
    var body: some View {
        VStack {
            Text("Food Menu")
                .font(.title)
                .padding()
            
            let today = Date()
            let calendar = Calendar.current

            // 오늘 날짜에 해당하는 메뉴 필터링
            let todayMenus = restaurantInfoManager.transformedMenus.filter { (date, _) in
                calendar.isDate(date, inSameDayAs: today)
            }
            

            ScrollView {

                if !todayMenus.isEmpty {
                    ForEach(todayMenus.keys.sorted(), id: \.self) { date in
                        if let menuItems = todayMenus[date] {
                            ForEach(menuItems.keys.sorted(), id: \.self) { menuID in
                                if let menuItem = menuItems[menuID],
                                   let restaurant = restaurantInfoManager.restaurantInfos.first(where: { $0.id == menuID }) {
                                    VStack(alignment: .leading) {
                                        Text("\(restaurant.name)")
                                            .font(.headline)
                                        Text("Breakfast: \(menuItem.breakfast ?? "N/A")")
                                        Text("Lunch: \(menuItem.lunch ?? "N/A")")
                                        Text("Dinner: \(menuItem.dinner ?? "N/A")")
                                        Text("Location: \(restaurant.latitude), \(restaurant.longitude)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("Building #: \(restaurant.building_number)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Divider()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                    }
                }
            
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
            restaurantInfoManager.fetchFoodMenu(date: Date())
        }

    }
    
    private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }

    
}
