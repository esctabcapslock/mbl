//
//  NetworkManager.swift
//  mbl
//
//  Created on 10/26/24.
//


import Foundation
import Combine
import SwiftSoup


class NetworkManager: ObservableObject {
    @Published var foodMenu: String = ""

    func fetchFoodMenu() {
        guard let url = URL(string: "https://snuco.snu.ac.kr/foodmenu/") else {
            print("Invalid URL")
            return
        }
        
        print("Starting network request to \(url)")


        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br, zstd", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("none", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("?1", forHTTPHeaderField: "Sec-Fetch-User")
        request.setValue("1", forHTTPHeaderField: "Sec-GPC")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // 응답 상태 코드 출력
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }


            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // 데이터 길이 출력
            print("Data received: \(data.count) bytes")

            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response string: \(responseString.prefix(100))...")
                DispatchQueue.main.async {
                    self.foodMenu = responseString
                }
            }else{
                print("Failed to convert data to string")
            }
        }
        task.resume()
    }
}
