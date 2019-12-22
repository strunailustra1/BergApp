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
    }
    
    @IBAction func changeStepper(_ sender: UIStepper) {
        guard let cartCell = sender.superview?.superview?.superview as? CartCell else { return }
        guard let indexPath = tableView.indexPath(for: cartCell) else { return }
        
        cart.addToCart(
            resource: cartItems[indexPath.row].resource,
            offer: cartItems[indexPath.row].offer,
            quantity: Int(sender.value)
        )
        
        updateCartElements()
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
        cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        CartCell.create(with: cartItems[indexPath.row], for: indexPath, tableView: tableView)
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cart.addToCart(
                resource: cartItems[indexPath.row].resource,
                offer: cartItems[indexPath.row].offer,
                quantity: 0
            )
            cartItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateCartElements()
        }
    }
}
