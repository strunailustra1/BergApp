//
//  Cart.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 22/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import Foundation

struct CartItem: Decodable, Encodable {
    var quantity: Int
    let resource: Resource
    let offer: Offer
    
    var amount: Float {
        (100 * Float(quantity) * (offer.price ?? 0)).rounded() / 100
    }

    mutating func changeQuantity(quantity: Int) {
        self.quantity = quantity
    }
}

class Cart {
    
    static let instance = Cart()
    
    private let userDefaults = UserDefaults.standard
    
    private var items: [String:CartItem] = [:]
    
    private let userDefaultsKey = "cartItems"
     
    var cartQuantity: Int {
        var quantity = 0
        for (_, item) in items {
            quantity += item.quantity
        }
        return quantity
    }
    
    var cartAmount: Float {
        var amount: Float = 0.0
        for (_, item) in items {
            amount += item.amount
        }
        return (100 * amount).rounded() / 100
    }
    
    init() {
        guard let cartItems = userDefaults.object(forKey: userDefaultsKey) as? Data else { return }
        guard let items = try? JSONDecoder().decode([String:CartItem].self, from: cartItems) else { return }
        
        self.items = items
    }
    
    func addToCart(resource: Resource, offer: Offer, quantity: Int) {
        let key = getKey(for:resource, offer: offer)
        if quantity > 0 {
            var resourceTmp = resource
            resourceTmp.clearOffers()
            items[key] = CartItem(quantity: quantity, resource: resourceTmp, offer: offer)
        } else {
            items[key] = nil
        }
        
        guard let cartItems = try? JSONEncoder().encode(items) else { return }
        userDefaults.set(cartItems, forKey: userDefaultsKey)
    }
    
    func getCartItems() -> [String:CartItem] {
        items
    }
    
    func getCartItemsArray() -> [CartItem] {
        var result: [CartItem] = []
        for (_, item) in items {
            result.append(item)
        }
        return result
    }
    
    func getCartItem(for resource: Resource, offer: Offer) -> CartItem? {
        let key = getKey(for: resource, offer: offer)
        return items[key]
    }
    
    private func getKey(for resource: Resource, offer: Offer) -> String {
        "\(resource.id ?? 0)-\(offer.warehouse?.id ?? 0)"
    }
}
