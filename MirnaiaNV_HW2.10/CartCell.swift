//
//  CartCell.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 22/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var warehouseNameLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var averagePeriodLabel: UILabel!
    @IBOutlet var reliabilityLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var orderQuantityLabel: UILabel!
    @IBOutlet var quantityStepper: UIStepper!
    
    func configure(with cartItem: CartItem) {
        titleLabel.text = cartItem.resource.titleText
        subtitleLabel.text = cartItem.resource.name
        priceLabel.text = String(cartItem.offer.price ?? 0) + "₽"
        quantityLabel.text = String(cartItem.offer.quantity ?? 0) + " шт."
        warehouseNameLabel.text = cartItem.offer.warehouse?.name ?? ""
        averagePeriodLabel.text = String(cartItem.offer.averagePeriod ?? 0) + " дн."
        reliabilityLabel.text = String(cartItem.offer.reliability ?? 0) + "%"
        quantityStepper.stepValue = Double(cartItem.offer.multiplicationFactor ?? 1)
        quantityStepper.maximumValue = Double(cartItem.offer.quantity ?? 1)

        quantityStepper.value = Double(cartItem.quantity)
        amountLabel.text = String(cartItem.amount) + "₽"
        orderQuantityLabel.text = String(cartItem.quantity)
    }

    static func create(with cartItem: CartItem, for indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartCell
        cell.configure(with: cartItem)
        return cell
    }
}
