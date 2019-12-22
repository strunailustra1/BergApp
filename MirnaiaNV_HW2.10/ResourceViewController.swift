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
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()

        navigationItem.title = resource.titleText
        
        fillAnalogueRows()
    }
    
    @IBAction func changeStepper(_ sender: UIStepper) {
        guard let offerCell = sender.superview?.superview?.superview as? OfferCell else { return }
        guard let indexPath = tableView.indexPath(for: offerCell) else { return }
        let offer = getOffer(for: indexPath)
        offerCell.orderQuantityLabel.text = String(Int(sender.value))
        offerCell.amountLabel.text = String((100 * sender.value * Double(offer.price ?? 0)).rounded() / 100) + "₽"
        offerCell.cartButton.isEnabled = sender.value > 0
    }
    
    private func getOffer(for indexPath: IndexPath) -> Offer {
        indexPath.section == 0 ? (resource.offers?[indexPath.row - 1])! : analoguesRows[indexPath.row] as! Offer
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
            return OfferCell.create(with: (resource.offers?[indexPath.row - 1])!, for: indexPath, tableView: tableView)
        }
        
        switch analoguesRows[indexPath.row] {
        case let resource as Resource:
            return ResourceCell.create(with: resource, for: indexPath, tableView: tableView)
        case let offer as Offer:
            return OfferCell.create(with: offer, for: indexPath, tableView: tableView)
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
