//
//  ViewController.swift
//  Project12M
//
//  Created by Romain Buewaert on 21/10/2021.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var picturesList = [PictureDetailed]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))

        let defaults = UserDefaults.standard
        if let savedPictures = defaults.object(forKey: "picturesList") as? Data {
            do {
                picturesList = try JSONDecoder().decode([PictureDetailed].self, from: savedPictures)
            } catch {
                print("Failed to load pictures.")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picturesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomTableViewCell else { return UITableViewCell() }
        let pictureDetailed = picturesList[indexPath.row]

        let path = getDocumentDirectory().appendingPathComponent(pictureDetailed.imageName)
        guard let image = UIImage(contentsOfFile: path.path) else { return UITableViewCell() }

        cell.configure(image: image, text: pictureDetailed.legend)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPicture = picturesList[indexPath.row]

        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.imageName = selectedPicture.imageName
            vc.title = selectedPicture.legend

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            picturesList.remove(at: indexPath.row)
            save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        dismiss(animated: true)

        enterLegend(imageName: imageName)
    }

    func enterLegend(imageName: String) {
        let ac = UIAlertController(title: "Enter Legend", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else { return }

            let pictureDetailed = PictureDetailed(imageName: imageName, legend: text)
            self?.picturesList.append(pictureDetailed)
            self?.save()
            self?.tableView.reloadData()
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    @objc func addPicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self

        let actionSheet = UIAlertController(title: "Picture Source", message: "Choose a source", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                imagePickerController.cameraCaptureMode = .photo
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
        }))

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Photo library not available")
            }
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    func save() {
        if let savedData = try? JSONEncoder().encode(picturesList) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "picturesList")
        } else {
            print("Failed to saved pictures.")
        }
    }
}
