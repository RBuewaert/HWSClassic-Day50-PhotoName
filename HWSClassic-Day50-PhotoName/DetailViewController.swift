//
//  DetailViewController.swift
//  Project12M
//
//  Created by Romain Buewaert on 21/10/2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var selectedImage: UIImageView!
    var imageName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let path = getDocumentDirectory().appendingPathComponent(imageName)
        guard let image = UIImage(contentsOfFile: path.path) else { return }

        selectedImage.image = image
    }

    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
