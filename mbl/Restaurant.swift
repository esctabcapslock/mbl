//
//  Restaurant.swift
//  mbl
//
//  Created on 10/26/24.
//

import Foundation

struct RestaurantInfo: Codable {
    let name: String
    let name_en: String
    let latitude: String // String으로 받아옴
    let longitude: String // String으로 받아옴
    let building_number: String
    let crawling_name: String?
    let id: Int
    let opening_hours: OpeningHours
}

struct OpeningHours: Codable {
    let weekdays: MealTimes
    let saturdays: MealTimes
    let sundays: MealTimes
}

struct MealTimes: Codable {
    let breakfast: [String]?
    let lunch: [String]?
    let dinner: [String]?
    let full: [String]?
}


struct MenuItem {
    let breakfast: String?
    let lunch: String?
    let dinner: String?
}


