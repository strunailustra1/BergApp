//
//  SearchResult.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

struct SearchResult: Decodable {
    let resources: [Resource]?
    let warnings: [SearchError]?
    let errors: [SearchError]?
}

struct SearchError: Decodable {
    let code: String?
    let text: String?
}

struct Brand: Decodable {
    let id: Int?
    let name: String?
}

struct Resource: Decodable {
    let id: Int?
    let article: String?
    let brand: Brand?
    let name: String?
    let offers: [Offer]?
    
    var titleText: String {
        "\(article ?? "") - \(brand?.name ?? "")"
    }
}

struct Warehouse: Decodable {
    let id: Int?
    let name: String?
    let type: Int?
}

struct Offer: Decodable {
    let warehouse: Warehouse?
    let price: Float?
    let average_period: Int?
    let assured_period: Int?
    let reliability: Int?
    let is_transit: Bool?
    let quantity: Int?
    let available_more: Bool?
    let multiplication_factor: Int?
    let delivery_type: Int?
}
