//
//  RestaurantInfoManager.swift
//  mbl
//
//  Created on 10/26/24.
//


import Foundation
import Combine

class RestaurantInfoManager: ObservableObject {
    @Published var restaurantInfos: [RestaurantInfo] = []
    private let networkManager = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    @Published var transformedMenus: [Date: [Int: MenuItem]] = [:]

    
    // Singleton pattern
    static let shared = RestaurantInfoManager()
    
    init() {
        loadRestaurantData()
        networkManager.$restaurantMenus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] menus in
                self?.transformMenus(menus)
            }
            .store(in: &cancellables)

    }
    
    // 1. JSON 파일에서 식당 정보 로드
    private func loadRestaurantData() {
        guard let url = Bundle.main.url(forResource: "RestaurantInfo", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            restaurantInfos = try decoder.decode([RestaurantInfo].self, from: data)
            print("Loaded restaurant locations: \(restaurantInfos)")
        } catch {
            print("Error loading JSON: \(error.localizedDescription)")
        }
    }
    
    // 2. 네트워크 크롤링
    func fetchFoodMenu(date: Date) {
        networkManager.fetchFoodMenu(date: date)
    }
    
    // 크롤링 데이터를 join함
    private func transformMenus(_ menus: [Date: [String: MenuItem]]) {
            
        for (date, items) in menus {
            var transformedItems: [Int: MenuItem] = [:]

            for (title, menuItem) in items {
                // crawling_name과 매칭되는 id 찾기
                if let matchingRestaurant = restaurantInfos.first(where: { $0.crawling_name == title }) {
                    transformedItems[matchingRestaurant.id] = menuItem
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return } // self가 nil인 경우 방지
                self.transformedMenus[date] = transformedItems
            }

        }

        print("Transformed menus: \(transformedMenus)")
    }
}
