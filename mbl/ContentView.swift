//
//  ContentView.swift
//  mbl
//
//  Created on 10/26/24.
//

import SwiftUI
import CoreLocation
import Combine


struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantInfoManager = RestaurantInfoManager()
//    @StateObject private var magnetometerManager = MagnetometerManager()


    
    var body: some View {
        VStack {
            Text("Food Menu")
                .font(.title)
                .padding()
            
//            Text("Magnetic Heading")
//                .font(.title)
//                .padding()

//            Text("\(magnetometerManager.magneticHeading, specifier: "%.2f")°")
//                .font(.largeTitle)
//                .padding()
            
//            Text("x,y,z = \(magnetometerManager.x), \(magnetometerManager.y), \(magnetometerManager.z)°")
//                .font(.largeTitle)
//                .padding()

            
//            if let heading = locationManager.heading {
////                Text("Heading: \(locationManager.heading)°")
////                Text("trueHeading: \(locationManager.heading?.trueHeading)°")
//                Text("magneticHeading: \((locationManager.heading?.magneticHeading))")
//            } else {
//                Text("Fetching heading...")
//            }

            
            
            // 오늘 날짜에 해당하는 메뉴 필터링
            if let todayMenus = getTodayMenus(today: Date()) {

                ScrollView {
                    if let userLocation = locationManager.location {
                        
//                        Text("\(locationManager.heading, specifier: "%.2f")°")
//                            .font(.title)
//                            .padding()

                        
                        
                        let sortedRestaurants = getSortedRestaurants(for: todayMenus, userLocation: userLocation)

                        ForEach(sortedRestaurants, id: \.restaurant.id) { entry in

                            let restaurant = entry.restaurant
                            if let menuItemsForRestaurant = todayMenus[restaurant.id] {
                                VStack(alignment: .leading) {
                                    Text(restaurant.name)
                                        .font(.headline)
                                    Text("Location: \(restaurant.latitude), \(restaurant.longitude)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    //                                    Text("방위각: \(String(format: "%.2f", entry.info.direction)) meters")
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        
                                        ArrowView(angle: entry.info.direction - (locationManager.heading?.magneticHeading ?? 0), size: 20) // 크기 설정
                                            .padding(.bottom, 5) //
                                        
                                        Text(distanceText(for: entry.info.distance))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                    }
                                    
                                    Text("Building #: \(restaurant.building_number)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("영업중: \(entry.info.openStatus)")
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
//                .onAppear {
//                    if let userLocation = locationManager.location {
//                        // 식당과의 거리 계산 및 정렬
//                        sortedRestaurants = getSortedRestaurants(for: todayMenus, userLocation: userLocation)
//                        print("apper, sortedRestaurants", sortedRestaurants)
//                    }
//                }
            } else {
                Text("오늘 이용 가능한 메뉴가 없습니다.")
                    .padding()
        }

//            if let location = locationManager.location {
//                Text("위도: \(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
//                    .padding()
//            }
           
        }
        .onAppear {
            print("onAppear ckeck")
            locationManager.startUpdatingLocation()
            restaurantInfoManager.fetchFoodMenu(date: Date())
            
        }
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
    
    
    func getSortedRestaurants(for todayMenus: [Int: Any], userLocation: CLLocation) -> [(restaurant: RestaurantInfo, info: (distance: CLLocationDistance,  openStatus: Bool, direction:Double))] {
        
        print("[getSortedRestaurants]", userLocation)
        var sortedRestaurants: [(restaurant: RestaurantInfo, info: (distance: CLLocationDistance,  openStatus: Bool, direction:Double))] = []

        for menuID in todayMenus.keys {
            if let restaurant = restaurantInfoManager.restaurantInfos.first(where: { $0.id == menuID }) {
                let restaurantLocation = CLLocation(latitude: Double(restaurant.latitude) ?? 0.0, longitude: Double(restaurant.longitude) ?? 0.0)
                let distance = userLocation.distance(from: restaurantLocation)
                let direction = userLocation.bearing(to: restaurantLocation)
                let openStatus = isRestaurantOpen(restaurant) // open_status에서 openStatus로 변경

                // SortedRestaurantItem 인스턴스를 추가
                sortedRestaurants.append((restaurant: restaurant, info: (distance: distance, openStatus: openStatus, direction:direction)))
            }
        }
        
        print("[sortedRestaurants]", sortedRestaurants)
        
        sortedRestaurants =  sortedRestaurants.sorted {
            if $0.info.openStatus != $1.info.openStatus {
                return $0.info.openStatus // Open restaurants come first
            }
            
            return $0.info.distance < $1.info.distance // Then sort by distance
        }
        
        print("[sortedRestaurants 2]", sortedRestaurants)

        
        return sortedRestaurants
    }


    // Function to check if a restaurant is open now or will open in 30 minutes
    private func isRestaurantOpen(_ restaurant: RestaurantInfo) -> Bool {
//        print("[isRestaurantOpen]", restaurant)
        
        let currentTime = Date()
        let calendar = Calendar.current
        let timeZone = TimeZone(abbreviation: "GMT-9")!
        
        // Get today's date in the specified timezone
        let today = calendar.dateComponents(in: timeZone, from: currentTime).weekday ?? 1

//        print("today",today)
        guard let openingHours = getOpeningHours(for: restaurant, on: today) else {
            return false
        }

        return isCurrentlyOpen(openingHours, in: timeZone) || willOpenInNext30Minutes(openingHours, from: currentTime, in: timeZone)
    }

    // Get opening hours based on the current day
    private func getOpeningHours(for restaurant: RestaurantInfo, on day: Int) -> MealTimes? {
        switch day {
        case 1: return restaurant.opening_hours.sundays
        case 2...6: return restaurant.opening_hours.weekdays
        case 7: return restaurant.opening_hours.saturdays
        default: return nil
        }
    }

    // Check if the restaurant is currently open
    private func isCurrentlyOpen(_ openingHours: MealTimes, in timeZone: TimeZone) -> Bool {
        let currentMinuteOfDay = currentMinuteOfDay(in: timeZone)
        
        return isOpen(for: openingHours.breakfast, currentMinute: currentMinuteOfDay) ||
               isOpen(for: openingHours.lunch, currentMinute: currentMinuteOfDay) ||
               isOpen(for: openingHours.dinner, currentMinute: currentMinuteOfDay) ||
               isOpen(for: openingHours.full, currentMinute: currentMinuteOfDay)
    }

    // Check if the restaurant will open in the next 30 minutes
    private func willOpenInNext30Minutes(_ openingHours: MealTimes, from currentTime: Date, in timeZone: TimeZone) -> Bool {
        let futureTime = Calendar.current.date(byAdding: .minute, value: 30, to: currentTime)!
        let futureMinuteOfDay = futureMinuteOfDay(futureTime, in: timeZone)
        
        return isOpen(for: openingHours.breakfast, currentMinute: futureMinuteOfDay) ||
               isOpen(for: openingHours.lunch, currentMinute: futureMinuteOfDay) ||
               isOpen(for: openingHours.dinner, currentMinute: futureMinuteOfDay)
    }

    // Helper function to determine if a meal is open at a specific time
    private func isOpen(for mealTimes: [String?]?, currentMinute: Int) -> Bool {
        guard let mealTimes = mealTimes else { return false }
        for time in mealTimes {
            if let timeString = time, let (start, end) = getMealTime(from: timeString) {
                if currentMinute >= start && currentMinute < end {
                    return true
                }
            }
        }
        return false
    }

    // Get current minute of the day in the specified timezone
    private func currentMinuteOfDay(in timeZone: TimeZone) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents(in: timeZone, from: currentDate)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return hour * 60 + minute
    }

    // Get future minute of the day in the specified timezone
    private func futureMinuteOfDay(_ date: Date, in timeZone: TimeZone) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: timeZone, from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return hour * 60 + minute
    }

    // Helper function to convert time string to (start, end) in minutes
    private func getMealTime(from timeString: String) -> (Int, Int)? {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return nil }
        
        let startTime = components[0] * 60 + components[1]
        let endTime = startTime + 30 // Assuming meals last 30 minutes for simplification
        return (startTime, endTime)
    }


}
