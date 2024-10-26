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
}

struct MenuItem {
    let breakfast: String?
    let lunch: String?
    let dinner: String?
}


