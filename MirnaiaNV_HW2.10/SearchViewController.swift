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
        
        setupSearchController()
        
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
            NetworkManager.instance.fetchResourcesAlamofire(for: article, brand: brand) { result, _ in
                for resource in (result.resources ?? []) {
                    if resource.isEquals(by: article) {
                        resourceVC.resource = resource
                    } else {
                        resourceVC.analogues.append(resource)
                    }
                }
                
                DispatchQueue.main.async {
                    resourceVC.activityIndicator.stopAnimating()
                    resourceVC.fillAnalogueRows()
                    resourceVC.tableView.reloadData()
                }
            }
        case let resources as (Resource, [Resource]):
            (resourceVC.resource, resourceVC.analogues) = resources
        default:
            return
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = resourceVC.resource.article
        navigationItem.backBarButtonItem = backItem
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Артикул, 65550, GDB1044"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let article = searchBar.text {
            resources = []
            tableView.reloadData()
            activityIndicator.startAnimating()
            NetworkManager.instance.fetchResourcesAlamofire(for: article) { result, response in
                DispatchQueue.main.async {
                    //let httpResponse = response as! HTTPURLResponse
                    // по артикулу найден один ресурс, тогда переходим к нему
                    // если по артикулу найдено несколько ресурсов, то получаем 300 код ответа
                    if response?.statusCode == 200 {
                        var searchResource: Resource?
                        var analogues: [Resource] = []
                        for resource in (result.resources ?? []) {
                            if resource.isEquals(by: article) {
                                searchResource = resource
                            } else {
                                analogues.append(resource)
                            }
                        }
                        if let searchResource = searchResource {
                            self.resources = [searchResource]
                            self.performSegue(withIdentifier: "goToResource", sender: (searchResource, analogues))
                        }
                    } else {
                        self.resources = result.resources ?? []
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
}
