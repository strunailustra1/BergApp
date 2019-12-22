//
//  CartViewController.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 22/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    @IBOutlet var quantityCartLabel: UILabel!
    @IBOutlet var amountCartLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let cart = Cart.instance
    
    var cartItems: [CartItem]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCartElements()
        
        //print(cartItems.count)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard segue.identifier == "resourceItem" else { return }
//        if let indexPath = tableView.indexPathForSelectedRow {
//            let detailVC = segue.destination as! ResourceDetailViewController
//            detailVC.resource = cartItems[indexPath.row].resource
//        }
//    }
    
    func updateCartElements() {
        quantityCartLabel.text = String(cart.cartQuantity)
        amountCartLabel.text = String(cart.cartAmount) + "₽"
        cartItems = cart.getCartItemsArray()
        tableView.reloadData()
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cartItems.count)
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        CartCell.create(with: cartItems[indexPath.row], for: indexPath, tableView: tableView)
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cart.addToCart(cartItem: CartItem(
                quantity: 0,
                resource: cartItems[indexPath.row].resource,
                offer: cartItems[indexPath.row].offer
            ))
            cartItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateCartElements()
        }
    }
}
