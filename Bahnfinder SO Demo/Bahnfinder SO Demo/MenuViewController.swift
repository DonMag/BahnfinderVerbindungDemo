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
	@IBOutlet var liveOptions: UIStackView!
	@IBOutlet var timeSwitch: UISwitch!
	@IBOutlet var datePicker: UIDatePicker!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		title = "Menu"
		
		segCtrl.selectedSegmentIndex = 0
		timeSwitch.isOn = false
		datePicker.isHidden = true
		
    }
	
	@IBAction func segChanged(_ sender: Any) {
		guard let sc = sender as? UISegmentedControl else { return }

		if sc.selectedSegmentIndex == 1 {
			// "Last Saved" is selected, make sure we have a saved trip
			let fullURL = getDocumentsDirectory().appendingPathComponent("saved.trips")
			let filePath = fullURL.path
			let fileManager = FileManager.default
			if !fileManager.fileExists(atPath: filePath) {
				let alertController = UIAlertController(title: "Alert", message: "No Saved Trip Found", preferredStyle: .alert)
				let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
				}
				alertController.addAction(OKAction)
				self.present(alertController, animated: true, completion:nil)
				sc.selectedSegmentIndex = 0
				return
			}
		}

		liveOptions.isHidden = sc.selectedSegmentIndex != 0
	}
	
	@IBAction func timeSwitchChanged(_ sender: Any) {
		guard let sw = sender as? UISwitch else { return }
		datePicker.isHidden = !sw.isOn
	}
	
	@IBAction func dateChanged(_ sender: Any) {
		guard let picker = sender as? UIDatePicker else { return }
		print(picker.date)
	}
	
	@IBAction func btnTapped(_ sender: Any) {
		guard let btn = sender as? UIButton,
			  let t = btn.configuration?.title
		else { return }
		
		if segCtrl.selectedSegmentIndex == 1 {
			// "Last Saved" is selected
			let fullURL = getDocumentsDirectory().appendingPathComponent("saved.trips")
			if t == "Original" {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "detailVerbindung") as? detailVerbindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = fullURL
					vc.title = "Original - Saved"
					navigationController?.pushViewController(vc, animated: true)
				}
			} else {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "donMagDetailVerbindung") as? DonMagDetailVergindungViewController {
					vc.loadTripsFrom = .saved
					vc.savedTripsURL = fullURL
					vc.title = "DonMag - Saved"
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
					if timeSwitch.isOn {
						vc.liveDateTime = datePicker.date
					}
					vc.title = "Original - Live"
					navigationController?.pushViewController(vc, animated: true)
				}
			} else {
				if let vc = storyboard?.instantiateViewController(withIdentifier: "donMagDetailVerbindung") as? DonMagDetailVergindungViewController {
					vc.loadTripsFrom = .live
					if timeSwitch.isOn {
						vc.liveDateTime = datePicker.date
					}
					vc.title = "DonMag - Live"
					navigationController?.pushViewController(vc, animated: true)
				}
			}
			return
		}
		
	}
	
	
}
