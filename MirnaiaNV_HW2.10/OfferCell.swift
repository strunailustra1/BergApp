//
//  OfferCell.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class OfferCell: UITableViewCell {
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var warehouseNameLabel: UILabel!
    @IBOutlet var averagePeriodLabel: UILabel!
    @IBOutlet var reliabilityLabel: UILabel!
    
    func configure(with offer: Offer) {
        priceLabel.text = String(offer.price ?? 0) + "₽"
        quantityLabel.text = String(offer.quantity ?? 0) + " шт."
        warehouseNameLabel.text = offer.warehouse?.name ?? ""
        averagePeriodLabel.text = String(offer.averagePeriod ?? 0) + " дн."
        reliabilityLabel.text = String(offer.reliability ?? 0) + "%"
    }
    
    static func create(with offer: Offer, for indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerCell", for: indexPath) as! OfferCell
        cell.configure(with: offer)
        return cell
    }
}
