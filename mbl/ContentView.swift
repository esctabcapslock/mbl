//
//  ContentView.swift
//  mbl
//
//  Created on 10/26/24.
//

import SwiftUI
import CoreLocation

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
            if let todayMenus = getTodayMenus(today: Date()) {

                ScrollView {
                    if let userLocation = locationManager.location {
                        
                        // 식당과의 거리 계산 및 정렬
                        let sortedRestaurants = calculateDistances(for: todayMenus, userLocation: userLocation)
                        
                        ForEach(sortedRestaurants, id: \.restaurant.id) { entry in
                            let restaurant = entry.restaurant
                            if let menuItemsForRestaurant = todayMenus[entry.restaurant.id] {
                                VStack(alignment: .leading) {
                                    Text(restaurant.name)
                                        .font(.headline)
                                    Text("Location: \(restaurant.latitude), \(restaurant.longitude)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Distance: \(String(format: "%.2f", entry.distance)) meters")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Building #: \(restaurant.building_number)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Breakfast: \(menuItemsForRestaurant.breakfast ?? "N/A")")
                                    Text("Lunch: \(menuItemsForRestaurant.lunch ?? "N/A")")
                                    Text("Dinner: \(menuItemsForRestaurant.dinner ?? "N/A")")
                                    Divider()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                    }   else {
                        Text("위치 정보를 가져오는 중...")
                            .padding()
                    }

                }
            } else {
                Text("오늘 이용 가능한 메뉴가 없습니다.")
                    .padding()
        }

            if let location = locationManager.location {
                Text("위도: \(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
                    .padding()
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            restaurantInfoManager.fetchFoodMenu(date: Date())
        }
    }
    
    private func calculateDistances(for todayMenus: [Int: MenuItem], userLocation: CLLocation) -> [(restaurant: RestaurantInfo, distance: CLLocationDistance)] {
        
        print("todayMenus",todayMenus)
        
        var sortedRestaurants: [(restaurant: RestaurantInfo, distance: CLLocationDistance)] = []

        
        for menuID in todayMenus.keys {
            if let restaurant = restaurantInfoManager.restaurantInfos.first(where: { $0.id == menuID }) {
                let restaurantLocation = CLLocation(latitude: Double(restaurant.latitude) ?? 0.0, longitude: Double(restaurant.longitude) ?? 0.0)
                let distance = userLocation.distance(from: restaurantLocation)
                sortedRestaurants.append((restaurant: restaurant, distance: distance))
            }
            
        }

        // 거리 기준으로 정렬
        return sortedRestaurants.sorted { $0.distance < $1.distance }
    }
    
    func getTodayMenus(today: Date) -> [Int: MenuItem]? {
        let calendar = Calendar.current

        // 오늘 날짜에 해당하는 메뉴 필터링
        let todayMenus = restaurantInfoManager.transformedMenus.filter { (date, _) in
            calendar.isDate(date, inSameDayAs: today)
        }

        // 첫 번째 키에 해당하는 메뉴 반환
        return todayMenus.keys.first.flatMap { todayMenus[$0] }
    }

}
