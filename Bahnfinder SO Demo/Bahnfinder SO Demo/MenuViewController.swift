//
//  MenuViewController.swift
//  Bahnfinder SO Demo
//
//  Created by Don Mag on 3/1/23.
//

import UIKit

enum LoadTripsFrom: Int {
	case live, saved
}

class MenuViewController: UIViewController {

	@IBOutlet var segCtrl: UISegmentedControl!
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }

	@IBAction func btnTapped(_ sender: Any) {
		guard let btn = sender as? UIButton,
			  let t = btn.configuration?.title
		else { return }
		
		var loadTripsFrom: LoadTripsFrom = .live
		var savedTripsURL: URL?

		if segCtrl.selectedSegmentIndex == 2 {
			// "Last Saved" is selected, make sure we have a saved trip
			let fullURL = getDocumentsDirectory().appendingPathComponent("saved.trips")
			let filePath = fullURL.path
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: filePath) {
				print("No Saved Trip")
				return
			}
			if t == "Original" {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "detailVerbindung") as? detailVerbindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = fullURL
					navigationController?.pushViewController(vc, animated: true)
				}
			} else {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "donMagDetailVerbindung") as? DonMagDetailVergindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = fullURL
					navigationController?.pushViewController(vc, animated: true)
				}
			}
			return
		}
		
		if segCtrl.selectedSegmentIndex == 1 {
			// "Sample Trip" is selected, so use the sample from the bundle
			let urlPath = Bundle.main.url(forResource: "sample", withExtension: "trips")
			if t == "Original" {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "detailVerbindung") as? detailVerbindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = urlPath
					navigationController?.pushViewController(vc, animated: true)
				}
			} else {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "donMagDetailVerbindung") as? DonMagDetailVergindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = urlPath
					navigationController?.pushViewController(vc, animated: true)
				}
			}
			return
		}
		
		if segCtrl.selectedSegmentIndex == 0 {
			// "Live" is selected
			if t == "Original" {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "detailVerbindung") as? detailVerbindungViewController {
					vc.loadTripsFrom = .live
					navigationController?.pushViewController(vc, animated: true)
				}
			} else {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "donMagDetailVerbindung") as? DonMagDetailVergindungViewController {
					vc.loadTripsFrom = .live
					navigationController?.pushViewController(vc, animated: true)
				}
			}
			return
		}
		
	}
	
	
}
