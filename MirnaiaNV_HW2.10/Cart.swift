//
//  Cart.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 22/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

struct CartItem {
    let quantity: Int
    let resource: Resource
    let offer: Offer
    
    var amount: Float {
        (100 * Float(quantity) * (offer.price ?? 0)).rounded() / 100
    }
    
    var key: String {
        "\(resource.id ?? 0)-\(offer.warehouse?.id ?? 0)"
    }
}

class Cart {
    
    static let instance = Cart()
    
    private var items: [String:CartItem] = [:]
     
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
    
    func addToCart(cartItem: CartItem) {
        if cartItem.quantity > 0 {
            items[cartItem.key] = cartItem
        } else {
            items[cartItem.key] = nil
        }
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
}
