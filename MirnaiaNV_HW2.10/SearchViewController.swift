//
//  SearchViewController.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    var resources: [Resource] = []
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Артикул, 65550, GDB1044"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        tableView.backgroundView = activityIndicator
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ResourceCell.create(with: resources[indexPath.row], for: indexPath, tableView: tableView) 
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToResource", sender: resources[indexPath.row])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goToResource" else { return }
        
        let resourceVC = segue.destination as! ResourceViewController
        
        switch sender {
        case let resource as Resource:
            guard let article = resource.article else { return }
            guard let brand = resource.brand?.name else { return }
            resourceVC.resource = resource
            NetworkManager.instance.fetchResources(for: article, brand: brand, resourceVC: resourceVC)
        case let resources as (Resource, [Resource]):
            (resourceVC.resource, resourceVC.analogues) = resources
        default:
            return
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = resourceVC.resource.article
        navigationItem.backBarButtonItem = backItem
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let article = searchBar.text {
            resources = []
            tableView.reloadData()
            activityIndicator.startAnimating()
            NetworkManager.instance.fetchResources(for: article, searchVC: self)
        }
    }
}
