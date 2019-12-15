//
//  SearchViewController.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    private var resources: [Resource] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! ResourceCell
        cell.configure(with: resources[indexPath.row])
        return cell
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
            resourceVC.fetchResources(for: article, brand: brand)
        case let resources as (Resource, [Resource]):
            (resourceVC.resource, resourceVC.analogues) = resources
        default:
            return
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let article = searchBar.text {
            resources = []
            tableView.reloadData()
            activityIndicator.startAnimating()
            fetchResources(for: article)
        }
    }
    
    func fetchResources(for article: String) {
        guard let escapedArticle = article.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let apiUrl = "https://api.berg.ru/ordering/get_stock.json?items[0][resource_article]=\(escapedArticle)&analogs=1&key=2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e730"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let apiResult = try JSONDecoder().decode(SearchResult.self, from: data)
                
                DispatchQueue.main.async {
                    let httpResponse = response as! HTTPURLResponse
                    // по артикулу найден один ресурс, тогда переходим к нему
                    // если по артикулу найдено несколько ресурсов, то получаем 300 код ответа
                    if httpResponse.statusCode == 200 {
                        var searchResource: Resource?
                        var analogues: [Resource] = []
                        for resource in (apiResult.resources ?? []) {
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
                        self.resources = apiResult.resources ?? []
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
                print(error)
            }
        }.resume()
    }
}
