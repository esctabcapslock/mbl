import Foundation

// 메뉴 항목을 표현하는 구조체
struct MenuInfoItem {
    var name: String
    var price: String
}

// 식당 정보를 표현하는 구조체
struct Restaurant {
    var name: String
    var operatingHours: String
    var MenuInfoItems: [MenuInfoItem]
}

// 문자열에서 운영 시간과 메뉴를 추출하는 함수
func parseRestaurantInfo(from input: String) -> Restaurant? {
    var restaurantName: String = ""
    var operatingHours: String = ""
    var MenuInfoItems: [MenuInfoItem] = []

    // 입력 문자열을 줄 단위로 나눕니다.
    let lines = input.components(separatedBy: .newlines)

    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

        // 식당 이름을 추출
        if trimmedLine.hasPrefix("[") && trimmedLine.hasSuffix("]") {
            restaurantName = String(trimmedLine.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
            continue
        }

        // 운영 시간을 찾습니다.
        if trimmedLine.contains("운영시간") || trimmedLine.contains("혼잡시간") {
            if let range = trimmedLine.range(of: "운영시간") ?? trimmedLine.range(of: "혼잡시간") {
                operatingHours = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            continue
        }

        // 메뉴와 가격을 찾습니다.
        let menuComponents = trimmedLine.components(separatedBy: ":")
        if menuComponents.count == 2,
           let name = menuComponents.first?.trimmingCharacters(in: .whitespaces),
           let price = menuComponents.last?.trimmingCharacters(in: .whitespaces) {
            let cleanedPrice = price.replacingOccurrences(of: "원", with: "").trimmingCharacters(in: .whitespaces)
            let MenuInfoItem = MenuInfoItem(name: name, price: cleanedPrice)
            MenuInfoItems.append(MenuInfoItem)
        }
    }

    // 식당 이름이 존재하면 메뉴 이름을 변경합니다.
    if !restaurantName.isEmpty {
        MenuInfoItems = MenuInfoItems.map { MenuInfoItem(name: "\(restaurantName)-\($0.name)", price: $0.price) }
    }

    return Restaurant(name: restaurantName, operatingHours: operatingHours, MenuInfoItems: MenuInfoItems)
}


