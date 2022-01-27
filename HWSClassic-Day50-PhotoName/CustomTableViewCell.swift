//
//  CustomTableViewCell.swift
//  Project12M
//
//  Created by Romain Buewaert on 21/10/2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var legendLabel: UILabel!
    @IBOutlet weak var imageDetailedView: UIImageView!

    func configure(image: UIImage, text: String) {
        imageDetailedView.image = image
        legendLabel.text = text
    }
}
