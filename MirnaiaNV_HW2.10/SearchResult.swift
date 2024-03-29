//
//  SearchResult.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import Foundation

let searchNumberRegex = try! NSRegularExpression(pattern: "[^A-ZА-Я0-9]", options: NSRegularExpression.Options.caseInsensitive)

struct SearchResult: Decodable {
    let resources: [Resource]?
    let warnings: [SearchError]?
    let errors: [SearchError]?
}

struct SearchError: Decodable {
    let code: String?
    let text: String?
}

struct Brand: Decodable, Encodable {
    let id: Int?
    let name: String?
}

struct Resource: Decodable, Encodable {
    let id: Int?
    let article: String?
    let brand: Brand?
    let name: String?
    var offers: [Offer]?
    
    var titleText: String {
        "\(article ?? "") - \(brand?.name ?? "")"
    }
    
    var searchNumber: String {
        getSearchNumber(by: article ?? "")
    }
    
    mutating func clearOffers() {
        offers = []
    }
    
    func isEquals(by article: String) -> Bool {
        getSearchNumber(by: article) == searchNumber
    }
    
    private func getSearchNumber(by article: String) -> String {
        // preg_replace('/[^A-ZА-Я0-9]/u', '', mb_strtoupper($article, 'UTF-8'))
        let articleUpper = article.uppercased()
        return searchNumberRegex.stringByReplacingMatches(
            in: articleUpper,
            options: [],
            range: NSMakeRange(0, article.count),
            withTemplate: ""
        )
    }
}

struct Warehouse: Decodable, Encodable {
    let id: Int?
    let name: String?
    let type: Int?
}

struct Offer: Decodable, Encodable {
    let warehouse: Warehouse?
    let price: Float?
    let averagePeriod: Int?
    let assuredPeriod: Int?
    let reliability: Int?
    let isTransit: Bool?
    let quantity: Int?
    let availableMore: Bool?
    let multiplicationFactor: Int?
    let deliveryType: Int?
}
