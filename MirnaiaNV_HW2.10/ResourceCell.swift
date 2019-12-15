//
//  ResourceCell.swift
//  MirnaiaNV_HW2.10
//
//  Created by Наталья Мирная on 15/12/2019.
//  Copyright © 2019 Наталья Мирная. All rights reserved.
//

import UIKit

class ResourceCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    func configure(with resource: Resource) {
        titleLabel.text = resource.titleText
        subtitleLabel.text = resource.name ?? ""
    }
}
