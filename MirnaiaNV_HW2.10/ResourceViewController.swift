//
//  ResourceViewController.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class ResourceViewController: UITableViewController {

    var resource: Resource!
    var analogues: [Resource] = []
    var analoguesRows: [Any] = []
    
    let cart = Cart.instance
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        fillAnalogueRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = resource.titleText

        tableView.reloadData()
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func changeStepper(_ sender: UIStepper) {
        guard let offerCell = sender.superview?.superview?.superview as? OfferCell else { return }
        guard let indexPath = tableView.indexPath(for: offerCell) else { return }
        
        let offer = getOffer(for: indexPath)
        let resource = getResource(for: indexPath)
        let cartItem = cart.getCartItem(for: resource, offer: offer)
        offerCell.orderQuantityLabel.text = String(Int(sender.value))
        offerCell.amountLabel.text = String((100 * sender.value * Double(offer.price ?? 0)).rounded() / 100) + "₽"
        offerCell.cartButton.isEnabled = sender.value > 0 || cartItem != nil
    }
    
    @IBAction func addToCart(_ sender: UIButton) {
        guard let offerCell = sender.superview?.superview?.superview as? OfferCell else { return }
        guard let indexPath = tableView.indexPath(for: offerCell) else { return }
        
        let offer = getOffer(for: indexPath)
        let resource = getResource(for: indexPath)
        let quantity = Int(offerCell.quantityStepper.value)
        
        cart.addToCart(resource: resource, offer: offer, quantity: quantity)
        
        let cartItem = cart.getCartItem(for: resource, offer: offer)
        offerCell.cartButton.isEnabled = quantity > 0 || cartItem != nil
    }
    
    private func getOffer(for indexPath: IndexPath) -> Offer {
        indexPath.section == 0 ? (resource.offers?[indexPath.row - 1])! : analoguesRows[indexPath.row] as! Offer
    }
    
    private func getResource(for indexPath: IndexPath) -> Resource {
        if indexPath.section == 0 {
            return resource
        }
        
        var row = indexPath.row - 1
        repeat {
            if let resource = analoguesRows[row] as? Resource {
                return resource
            }
            row -= 1
        } while true
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        analogues.count > 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return min((resource.offers?.count ?? 0), 5) + 1
        } else {
            var numberOfRowsInAnalogues = 0
            for resource in analogues {
                numberOfRowsInAnalogues += min((resource.offers?.count ?? 0), 5) + 1
            }
            return numberOfRowsInAnalogues
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Искомый товар" : "Аналоги"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            return ResourceCell.create(with: resource, for: indexPath, tableView: tableView)
        }
        
        if indexPath.section == 0 && indexPath.row != 0 {
            return OfferCell.create(with: (resource.offers?[indexPath.row - 1])!, resource: resource, for: indexPath, tableView: tableView)
        }
        
        switch analoguesRows[indexPath.row] {
        case let resource as Resource:
            return ResourceCell.create(with: resource, for: indexPath, tableView: tableView)
        case let offer as Offer:
            return OfferCell.create(with: offer, resource: getResource(for: indexPath), for: indexPath, tableView: tableView)
        default:
            return tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath) as! ResourceCell
        }
    }
    
    func fillAnalogueRows() {
        analoguesRows = []
        for resource in analogues {
            analoguesRows.append(resource)
            var offersCount = 0
            for offer in resource.offers ?? [] {
                analoguesRows.append(offer)
                offersCount += 1
                if offersCount == 5 {
                    break
                }
            }
        }
    }
}
