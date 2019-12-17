//
//  NetworkManager.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let instance = NetworkManager()
    
    let bergApiUrl = "https://api.berg.ru/ordering/get_stock.json"
    let bergApiKey = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e730"
    
    func fetchResources(for article: String, searchVC: SearchViewController) {
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
                            searchVC.resources = [searchResource]
                            searchVC.performSegue(withIdentifier: "goToResource", sender: (searchResource, analogues))
                        }
                    } else {
                        searchVC.resources = apiResult.resources ?? []
                    }
                    
                    searchVC.activityIndicator.stopAnimating()
                    searchVC.tableView.reloadData()
                }
            } catch {}
        }.resume()
    }
    
    func fetchResources(for article: String, brand: String, resourceVC: ResourceViewController) {
        guard let escapedArticle = article.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let escapedBrand = brand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let apiUrl = "https://api.berg.ru/ordering/get_stock.json?items[0][resource_article]=\(escapedArticle)&items[0][brand_name]=\(escapedBrand)&analogs=1&key=2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e730"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let apiResult = try JSONDecoder().decode(SearchResult.self, from: data)
                for resource in (apiResult.resources ?? []) {
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
            } catch {}
        }.resume()
    }
    
    func fetchResourcesAlamofire(for article: String, searchVC: SearchViewController) {
        request(bergApiUrl,
                method: .get,
                parameters: ["items": [["resource_article": article]],
                             "analogs": 1,
                             "key": bergApiKey],
                encoding: URLEncoding.default).validate(statusCode: 200..<301).responseData { dataResponse in
                    switch dataResponse.result {
                    case .success(let value):
                        do {
                            let apiResult = try JSONDecoder().decode(SearchResult.self, from: value)
                            
                            DispatchQueue.main.async {
                                //let httpResponse = response as! HTTPURLResponse
                                // по артикулу найден один ресурс, тогда переходим к нему
                                // если по артикулу найдено несколько ресурсов, то получаем 300 код ответа
                                if dataResponse.response?.statusCode == 200 {
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
                                        searchVC.resources = [searchResource]
                                        searchVC.performSegue(withIdentifier: "goToResource", sender: (searchResource, analogues))
                                    }
                                } else {
                                    searchVC.resources = apiResult.resources ?? []
                                }
                                
                                searchVC.activityIndicator.stopAnimating()
                                searchVC.tableView.reloadData()
                            }
                        } catch {}
                    case .failure(let error):
                        print(error)
                    }
        }
    }
    
    func fetchResourcesAlamofire(for article: String, brand: String, resourceVC: ResourceViewController) {
        request(bergApiUrl,
                method: .get,
                parameters: [
                    "items": [["resource_article":article],["brand_name":brand]],
                    "analogs": 1,
                    "key": bergApiKey],
                encoding: URLEncoding.default).validate().responseData { dataResponse in
                    switch dataResponse.result {
                    case .success(let value):
                        do {
                            let apiResult = try JSONDecoder().decode(SearchResult.self, from: value )
                            for resource in (apiResult.resources ?? []) {
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
                        } catch {}
                    case .failure(let error):
                        print(error)
                    }
        }
    }
}
