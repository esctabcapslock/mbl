//
//  NetworkManager.swift
//  mbl
//
//  Created on 10/26/24.
//

import Foundation
import Combine
import SwiftSoup

func removeParentheses(from title: String) -> String {
    return title.replacingOccurrences(of: " \\(.*?\\)", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
}


class NetworkManager: ObservableObject  {
    @Published var restaurantMenus:  [Date: [String: MenuItem]] = [:]
    
    private let menuURL = "https://snuco.snu.ac.kr/foodmenu/"
    private let headers: [String: String] = [
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "DNT": "1",
        "Connection": "keep-alive",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
    ]
    
    func fetchFoodMenu(date: Date) {
        //exampele: https://snuco.snu.ac.kr/foodmenu/?date=2024-10-30
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 원하는 형식 설정
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9") // 한국 시각 기준 날짜 설정
        
        let dateString = dateFormatter.string(from: date)
        
        guard let url = URL(string: "\(menuURL)?date=\(dateString)") else {
            print("Invalid URL")
            return
        }

        print("Starting network request to \(url)")
        performRequest(url: url, date: date)
    }

    private func performRequest(url: URL, date: Date) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.handleError(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received")
                return
            }

            self?.parseHTML(data: data, date: date)
        }
        task.resume()
    }

    private func parseHTML(data: Data, date: Date) {
        do {
            if restaurantMenus[date] == nil {
                restaurantMenus[date] = [:]
            }
                
            let htmlString = String(data: data, encoding: .utf8) ?? ""
            let document = try SwiftSoup.parse(htmlString)

            // 메뉴 테이블 추출
            let rows = try document.select(".menu-table tbody tr")

            for row in rows {
                let title = removeParentheses(from: try row.select(".title").text())
                let breakfast = try row.select(".breakfast").text()
                let lunch = try row.select(".lunch").text()
                let dinner = try row.select(".dinner").text()

                let menuItem = MenuItem(breakfast: breakfast.isEmpty ? nil : breakfast, lunch: lunch.isEmpty ? nil : lunch, dinner: dinner.isEmpty ? nil : dinner)
                
                if restaurantMenus[date]?[title] == nil {
                    restaurantMenus[date]?[title] = menuItem;
                }
            }
        } catch {
            print("Failed to parse HTML: \(error.localizedDescription)")
        }
    }

    private func handleError(_ error: Error) {
        print("Network request error: \(error.localizedDescription)")
    }
}
