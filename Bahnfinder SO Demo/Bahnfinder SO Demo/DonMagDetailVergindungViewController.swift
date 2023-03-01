//
//  DonMagDetailVergindungViewController.swift
//  Bahnfinder SO Demo
//
//  Created by Don Mag on 3/1/23.
//

import UIKit

import TripKit
import CoreLocation

class DonMagDetailVergindungViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var loadTripsFrom: LoadTripsFrom = .live
	var savedTripsURL: URL?
	
	var spinner = UIActivityIndicatorView()
	
	@IBOutlet var mainTableView: UITableView!
	@IBOutlet var durationLabel: UILabel!
	
	var resultTripsArray = [Trip]()
	var resultLegArray = [[[Leg]]]()
	var selectedIndex = 0
	let refreshControl = UIRefreshControl()
	var provider: NetworkProvider = currentProvider()
	var refreshContext = RefreshTripContext()
	
	@IBAction func closeBtn(_ sender: Any) {
		self.dismiss(animated: true)
	}
	
	@objc func saveTapped() {
		// save the resultTripsArray to "saved.trips"
		//	so we can re-load the same data
		saveTrips(tripsArray: resultTripsArray)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "DonMag Version"
		
		if navigationController != nil {
			// add a rightBarButtonItem so we can Save the current resultTripsArray
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
		}
		
		// add a UIActivityIndicatorView -- a "spinner"
		spinner.style = .large
		spinner.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spinner)
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: mainTableView.centerXAnchor),
			spinner.topAnchor.constraint(equalTo: mainTableView.topAnchor, constant: 30.0),
		])
		spinner.startAnimating()
		
		mainTableView.separatorStyle = .none

		Task { @MainActor in
			
			if loadTripsFrom == .saved,
			   let url = savedTripsURL,
			   let tmpTrips = Bahnfinder_SO_Demo.loadTripsFrom(url: url)
			{
				for (index, trip) in tmpTrips.enumerated() {
					resultTripsArray.append(trip)
					refreshContext = trip.refreshContext!
					var tempLeg = [[Leg]]()
					tempLeg.append(trip.legs)
					resultLegArray.append(tempLeg)
				}
				let waittimeDifference = resultTripsArray[selectedIndex].departureTime.distance(to: resultTripsArray[selectedIndex].arrivalTime)
				if waittimeDifference > 60*60 {
					durationLabel.text = "Dauer: \(waittimeDifference.stringFromTimeIntervalWithText())"
				} else {
					durationLabel.text = "Dauer: \(waittimeDifference.stringFromTimeIntervalWithText())"
				}
				
				spinner.stopAnimating()
				mainTableView.reloadData()
			}
			else
			{
				// This function is normally executed by the ViewController before:
				let d = Date()
				
				let (request, result) = await provider.queryTrips(from: Location(id: "A=1@O=Ratzeburg@X=10740635@Y=53698214@U=80@L=8004952@B=1@p=1677095209@"), via: nil, to: Location(id: "A=1@O=Kaiserstraße, Neubiberg@X=11666920@Y=48075399@u=120@U=80@L=622352@"), date: d)
				
				switch result {
				case .success(let context, let from, let via, let to, let trips, let messages):
					for (index, trip) in trips.enumerated() {
						resultTripsArray.append(trip)
						refreshContext = trip.refreshContext!
						var tempLeg = [[Leg]]()
						tempLeg.append(trip.legs)
						resultLegArray.append(tempLeg)
					}
					
					let waittimeDifference = resultTripsArray[selectedIndex].departureTime.distance(to: resultTripsArray[selectedIndex].arrivalTime)
					if waittimeDifference > 60*60 {
						durationLabel.text = "Dauer: \(waittimeDifference.stringFromTimeIntervalWithText())"
					} else {
						durationLabel.text = "Dauer: \(waittimeDifference.stringFromTimeIntervalWithText())"
					}
					
					//Dont work because TripKit See: https://github.com/alexander-albers/tripkit/issues/13
					//        refreshControl.attributedTitle = NSAttributedString(string: "Aktualisieren...")
					//        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
					//        mainTableView.addSubview(refreshControl)
					
					spinner.stopAnimating()
					mainTableView.reloadData()
					
				default: break
				}
			}
		}
		
	}
	
	
	@objc func refresh() {
		let tempTripsArray = resultTripsArray
		//DONT Work because TripKit See: https://github.com/alexander-albers/tripkit/issues/13
		Task { @MainActor in
			let (request, result) = await provider.refreshTrip(context: refreshContext)
			switch result {
			case .success(let context, let from, let via, let to, let trips, let messages):
				resultTripsArray.removeAll()
				resultLegArray.removeAll()
				mainTableView.reloadData()
				DispatchQueue.main.async {
					self.resultTripsArray = trips
					self.mainTableView.reloadData()
					
					for i in 0..<trips.count {
						var tempLeg = [[Leg]]()
						tempLeg.append(self.resultTripsArray[i].legs)
						self.resultLegArray.append(tempLeg)
					}
					
					
				}
			default:
				print("error reloading context")
			}
			refreshControl.endRefreshing()
		}
	}
	
	
	func generateArray() {
		
	}
	var expandedRowIndex = -1
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == expandedRowIndex {
			let tempPublicLeg = resultLegArray[selectedIndex][0][indexPath.row / 2] as! PublicLeg
			return CGFloat(71 + 20*tempPublicLeg.intermediateStops.count) //Expanded
		}
		return 71 //Not expanded
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard selectedIndex < resultLegArray.count else { return 0 }
		return resultLegArray[selectedIndex][0].count * 2 + 1
	}
	
	enum RowType: Int {
		case departure, arrival, connection, detail
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var sideColor = UIColor.clear
		var sideTopColor = UIColor.clear
		var sideBottomColor = UIColor.clear
		
		// for code readability...
		//	instead of a lot of resultLegArray[selectedIndex][0]
		let thisResultLeg = resultLegArray[selectedIndex]
		let thisLeg = thisResultLeg[0]
		let arrayIndex = indexPath.row / 2
		
		var rowType: RowType = .detail
		
		// let's first figure out which type of row we're on
		if indexPath.row % 2 == 0 {
			if indexPath.row == 0 {
				rowType = .departure
			} else if arrayIndex == thisLeg.count {
				rowType = .arrival
			} else {
				rowType = .connection
			}
		}
		
		// MARK: the First row
		if rowType == .departure {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath) as! BahnfinderDepartureCell
			
			cell.timeMiddleLabel.text = ""
			
			if thisLeg[arrayIndex] is PublicLeg {
				//print("PublicLeg")
				
				let tempPublicLeg = thisLeg[arrayIndex] as! PublicLeg
				if tempPublicLeg.departureStop.predictedTime == nil {
					cell.timeMiddleLabel.textColor = .label
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.plannedTime)
				} else if tempPublicLeg.departureStop.plannedTime == tempPublicLeg.departureStop.predictedTime {
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.predictedTime!)
					cell.timeMiddleLabel.textColor = UIColor.systemGreen
				} else {
					let timeDifference = tempPublicLeg.departureStop.plannedTime.distance(to: (tempPublicLeg.departureStop.predictedTime ?? tempPublicLeg.departureStop.plannedTime)!)
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.predictedTime!)
					cell.timeMiddleLabel.textColor = UIColor.systemRed
					if timeDifference.stringFromTimeIntervalOnlyNumber().contains("-") == true {
						cell.timeMiddleLabel.textColor = UIColor.systemBlue
					}
				}
				sideColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
			} else {
				//print("IndividualLeg")
				let tempIndLeg = thisLeg[arrayIndex] as! IndividualLeg
				sideColor = UIColor.lightGray
				cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempIndLeg.departureTime)
				cell.timeMiddleLabel.textColor = UIColor.label
			}
			
			cell.devLabel.isHidden = true
			cell.sideLineView.backgroundColor = sideColor
			cell.horzLineView.backgroundColor = sideColor
			cell.destinationLabel.text = thisLeg[arrayIndex].departure.name
			return cell
			
		}
		
		if rowType == .arrival {
			
			// MARK: the Last row
			let cell = tableView.dequeueReusableCell(withIdentifier: "arrivalCell", for: indexPath) as! BahnfinderArrivalCell
			
			cell.timeMiddleLabel.text = ""
			
			if thisLeg.last is PublicLeg {
				//print("PublicLeg")
				let tempPublicLeg = thisLeg.last as! PublicLeg
				if tempPublicLeg.arrivalStop.predictedTime == nil {
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.plannedArrivalTime)
					cell.timeMiddleLabel.textColor = UIColor.label
				} else if tempPublicLeg.arrivalStop.plannedTime == tempPublicLeg.arrivalStop.predictedTime {
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.plannedArrivalTime)
					cell.timeMiddleLabel.textColor = UIColor.systemGreen
				} else {
					let timeDifference = tempPublicLeg.plannedArrivalTime.distance(to: tempPublicLeg.arrivalTime )
					cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempPublicLeg.arrivalTime)
					cell.timeMiddleLabel.textColor = UIColor.systemRed
					if timeDifference.stringFromTimeIntervalOnlyNumber().contains("-") == true {
						cell.timeMiddleLabel.textColor = UIColor.systemBlue
					}
				}
				
				sideColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
			} else {
				//print("IndividualLeg")
				let tempIndLeg = thisLeg.last as! IndividualLeg
				cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempIndLeg.arrivalTime)
				cell.timeMiddleLabel.textColor = UIColor.label
				sideColor = UIColor.lightGray
			}
			
			cell.devLabel.isHidden = true
			cell.sideLineView.backgroundColor = sideColor
			cell.horzLineView.backgroundColor = sideColor
			cell.destinationLabel.text = thisLeg.last?.arrival.name
			return cell
			
		}
		
		if rowType == .connection {
			
			// MARK: a "Connection" row
			let cell = tableView.dequeueReusableCell(withIdentifier: "connectionCell", for: indexPath) as! BahnfinderConnectionCell
			
			cell.timeTopLabel.text = ""
			cell.timeBottomLabel.text = ""
			
			if thisLeg[arrayIndex] is PublicLeg {
				//print("PublicLeg")
				let tempPublicLeg = thisLeg[arrayIndex] as! PublicLeg
				
				if tempPublicLeg.departureStop.predictedTime == nil {
					cell.timeBottomLabel.textColor = .label
					cell.timeBottomLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.plannedTime)
				} else if tempPublicLeg.departureStop.plannedTime == tempPublicLeg.departureStop.predictedTime {
					cell.timeBottomLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.predictedTime!)
					cell.timeBottomLabel.textColor = UIColor.systemGreen
				} else {
					let timeDifference = tempPublicLeg.departureStop.plannedTime.distance(to: tempPublicLeg.departureStop.predictedTime! )
					cell.timeBottomLabel.text = timeFormatHHMM.string(from: tempPublicLeg.departureStop.predictedTime!)
					cell.timeBottomLabel.textColor = UIColor.systemRed
					if timeDifference.stringFromTimeIntervalOnlyNumber().contains("-") == true {
						cell.timeBottomLabel.textColor = UIColor.systemBlue
					}
				}
				sideBottomColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
			} else {
				//print("IndividualLeg")
				let tempIndLeg = thisLeg[arrayIndex] as! IndividualLeg
				sideBottomColor = UIColor.lightGray
				cell.timeBottomLabel.text = timeFormatHHMM.string(from: tempIndLeg.departureTime)
				cell.timeBottomLabel.textColor = UIColor.label
			}
			
			if thisLeg[arrayIndex-1] is PublicLeg { //Line before current
				//print("PublicLeg")
				let tempPublicLeg = thisLeg[arrayIndex-1] as! PublicLeg
				sideTopColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
				if tempPublicLeg.arrivalStop.predictedTime == nil {
					cell.timeTopLabel.textColor = .label
					cell.timeTopLabel.text = timeFormatHHMM.string(from: tempPublicLeg.arrivalStop.plannedTime)
				} else if tempPublicLeg.arrivalStop.plannedTime == tempPublicLeg.arrivalStop.predictedTime {
					cell.timeTopLabel.text = timeFormatHHMM.string(from: thisLeg[arrayIndex-1].arrivalTime)
					cell.timeTopLabel.textColor = UIColor.systemGreen
				} else {
					let timeDifference = thisLeg[arrayIndex-1].plannedArrivalTime.distance(to: thisLeg[arrayIndex-1].arrivalTime )
					cell.timeTopLabel.text = timeFormatHHMM.string(from: thisLeg[arrayIndex-1].arrivalTime)
					cell.timeTopLabel.textColor = UIColor.systemRed
					if timeDifference.stringFromTimeIntervalOnlyNumber().contains("-") == true {
						cell.timeTopLabel.textColor = UIColor.systemBlue
					}
				}
			} else {
				//print("IndividualLeg")
				let tempIndLeg = thisLeg[arrayIndex-1] as! IndividualLeg
				sideTopColor = UIColor.lightGray
				cell.timeTopLabel.text = timeFormatHHMM.string(from: tempIndLeg.arrivalTime)
				cell.timeTopLabel.textColor = UIColor.label
			}
			
			cell.devLabel.isHidden = true
			cell.sideTopLineView.backgroundColor = sideTopColor
			cell.horzTopLineView.backgroundColor = sideTopColor
			cell.sideBottomLineView.backgroundColor = sideBottomColor
			cell.horzBottomLineView.backgroundColor = sideBottomColor
			cell.destinationLabel.text = thisLeg.last?.arrival.name
			return cell
			
		}
		
		// MARK: a Detail row
		// (it was not a .departure, .arrival or .connection row)
		let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! BahnfinderDetailCell
		
		// dev only
		//cell.timeTopLabel.backgroundColor = .cyan
		//cell.timeMiddleLabel.backgroundColor = .yellow
		//cell.timeBottomLabel.backgroundColor = .green

		cell.timeTopLabel.isHidden = false
		cell.timeMiddleLabel.isHidden = true
		cell.timeBottomLabel.isHidden = false
		
		cell.timeTopLabel.text = " "
		cell.timeMiddleLabel.text = " "
		cell.timeBottomLabel.text = " "
		
		cell.timeSeperatorView.isHidden = true
		
		// we will show these if needed
		cell.chevronImageView.isHidden = true
		cell.intermediateTableView.isHidden = true
		
		cell.lineNumberLabel.isHidden = true
		cell.walkImgView.isHidden = true
		
		if thisLeg[arrayIndex] is PublicLeg {
			//Fahrzeug
			//print("PublicLeg")
			let tempPublicLeg = thisLeg[arrayIndex] as! PublicLeg
			cell.lineNumberLabel.isHidden = false
			cell.lineNumberLabel.text = tempPublicLeg.line.label ?? ""
			cell.destinationLabel.text = tempPublicLeg.destination?.name
			
			// not clear what we're doing with this "backgroundLineHalfHalf"?
			//	in any case, we do NOT want to be adding subviews to the cell here
			//	if it is to "stylize" the lineNumberLabel, that should be part of
			//	the functionality of the custom label in the cell itself
			if tempPublicLeg.line.style.backgroundColor2 == nil || tempPublicLeg.line.style.backgroundColor2 == 0 {
				cell.lineNumberLabel.backgroundColorC = tempPublicLeg.line.style.backgroundColor
			} else {
				cell.lineNumberLabel.backgroundColorC = UInt32(UIColor.clear.hexa)
				//					let backgroundLineHalfHalf = LineHalfTriangleView(frame: cell.lineNumberLabel.frame)
				//					backgroundLineHalfHalf.topColor = tempPublicLeg.line.style.backgroundColor
				//					backgroundLineHalfHalf.bottomColor = tempPublicLeg.line.style.backgroundColor2
				//					backgroundLineHalfHalf.borderColor = tempPublicLeg.line.style.borderColor
				//					cell.contentView.addSubview(backgroundLineHalfHalf)
				//					cell.contentView.sendSubviewToBack(backgroundLineHalfHalf)
			}
			cell.lineNumberLabel.shape = tempPublicLeg.line.style.shape
			cell.lineNumberLabel.foregroundColor = tempPublicLeg.line.style.foregroundColor
			cell.lineNumberLabel.borderColor = tempPublicLeg.line.style.borderColor
			//				if tempPublicLeg.line.style.backgroundColor2 == nil || tempPublicLeg.line.style.backgroundColor2 == 0 {
			//					cell.lineNumberLabel.backgroundColorC = tempPublicLeg.line.style.backgroundColor
			//				} else {
			//					cell.lineNumberLabel.backgroundColorC = UInt32(UIColor.clear.hexa)
			//					let backgroundLineHalfHalf = LineHalfTriangleView(frame: cell.lineNumberLabel.frame)
			//					backgroundLineHalfHalf.topColor = tempPublicLeg.line.style.backgroundColor
			//					backgroundLineHalfHalf.bottomColor = tempPublicLeg.line.style.backgroundColor2
			//					backgroundLineHalfHalf.borderColor = tempPublicLeg.line.style.borderColor
			//					cell.contentView.addSubview(backgroundLineHalfHalf)
			//					cell.contentView.sendSubviewToBack(backgroundLineHalfHalf)
			//				}
			//MARK: Info PublicLeg Time
			if tempPublicLeg.departureTime == tempPublicLeg.plannedDepartureTime {
				
			} else {
				let timeDifference = tempPublicLeg.plannedDepartureTime.distance(to: tempPublicLeg.departureTime )
				cell.timeTopLabel.text = timeDifference.stringFromTimeIntervalWithText()
				cell.timeTopLabel.textColor = UIColor.systemRed
				//cell.timeTopLabel.isHidden = false
				cell.timeTopLabel.text = "+ \(timeDifference.stringFromTimeIntervalOnlyNumber())"
				cell.timeSeperatorView.isHidden = false
				if cell.timeTopLabel.text?.contains("-") == true {
					cell.timeTopLabel.text = cell.timeTopLabel.text?.replacingOccurrences(of: "+ ", with: "")
					cell.timeTopLabel.text = cell.timeTopLabel.text?.replacingOccurrences(of: "-", with: "- ")
					cell.timeTopLabel.textColor = UIColor.systemBlue
				}
			}
			if tempPublicLeg.arrivalTime == tempPublicLeg.plannedArrivalTime {
			} else {
				let timeDifference = tempPublicLeg.plannedArrivalTime.distance(to: tempPublicLeg.arrivalTime )
				cell.timeBottomLabel.text = timeDifference.stringFromTimeIntervalWithText()
				cell.timeBottomLabel.textColor = UIColor.systemRed
				//cell.timeBottomLabel.isHidden = false
				cell.timeBottomLabel.text = "+ \(timeDifference.stringFromTimeIntervalOnlyNumber())"
				cell.timeSeperatorView.isHidden = false
				if cell.timeBottomLabel.text?.contains("-") == true {
					cell.timeBottomLabel.text = cell.timeBottomLabel.text?.replacingOccurrences(of: "+ ", with: "")
					cell.timeBottomLabel.text = cell.timeBottomLabel.text?.replacingOccurrences(of: "-", with: "- ")
					cell.timeBottomLabel.textColor = UIColor.systemBlue
				}
			}
			if cell.timeTopLabel.text == cell.timeBottomLabel.text {
				cell.timeTopLabel.isHidden = true
				cell.timeBottomLabel.isHidden = true
				cell.timeMiddleLabel.isHidden = false
				cell.timeMiddleLabel.text = cell.timeTopLabel.text
				cell.timeMiddleLabel.textColor = cell.timeTopLabel.textColor
				cell.timeSeperatorView.isHidden = true
			}
			sideColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
			
			//Expandable Cell
			cell.intermediateStops = tempPublicLeg.intermediateStops
			
			cell.sideColor = sideColor
			
			if tempPublicLeg.intermediateStops.count >= 0 {
				cell.chevronImageView.isHidden = false
				if cell.frame.height > 72 {
					cell.chevronImageView.image = UIImage(systemName: "chevron.up")
				} else {
					cell.chevronImageView.image = UIImage(systemName: "chevron.down")
				}
			}
			
			cell.intermediateTableView.isHidden = indexPath.row != expandedRowIndex
			
		} else {
			//Walk
			//print("IndividualLeg")
			let tempIndLeg = thisLeg[arrayIndex] as! IndividualLeg
			// cells are reused, so clear any intermediateStops that may have been set previously
			cell.intermediateStops = []
			cell.walkImgView.isHidden = false
			cell.destinationLabel.text = "Fußweg: \(tempIndLeg.departure.getDistanceText(CLLocation(latitude: CLLocationDegrees(tempIndLeg.arrival.coord?.lat ?? 0)/1000000, longitude: CLLocationDegrees(tempIndLeg.arrival.coord?.lon ?? 0)/1000000)))"
			sideColor = UIColor.lightGray
		}
		
		cell.devLabel.isHidden = true
		cell.sideLineView.backgroundColor = sideColor
		
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var cellsToReload: [IndexPath] = []
		
		if let c = tableView.cellForRow(at: indexPath) as? BahnfinderDetailCell,
		   c.intermediateStops.count > 0
		{
			// we've tapped on an "Expandable" row
			//	so we know we will need to reload the tapped row
			cellsToReload.append(indexPath)
			
			// if the row is already EXPANDED
			if expandedRowIndex == indexPath.row {
				expandedRowIndex = -1
			} else {
				// if a DIFFERENT row is Expanded, we need to reload it
				//	to its Collapsed state
				if expandedRowIndex > -1 {
					cellsToReload.append(IndexPath(row: expandedRowIndex, section: 0))
				}
				// now set this row as the Expanded row
				expandedRowIndex = indexPath.row
			}
			tableView.reloadRows(at: cellsToReload, with: .automatic)
		}
		else
		{
			// we've tapped on a "Non-Expandable" row
			tableView.deselectRow(at: indexPath, animated: false)
		}
		
	}
	
}
extension DonMagDetailVergindungViewController: verbindungDetailProtocol {
	var protocolRefreshContext: RefreshTripContext? {
		set {
			print("SET protocolRefreshContext")
			refreshContext = newValue!
		}
		get {
			return refreshContext
		}
	}
	
	var protocolTripArray: [Trip]? {
		set {
			print("SET")
			resultTripsArray = newValue!
		}
		get {
			return resultTripsArray
		}
	}
	var protocolLegArray: [[[Leg]]]? {
		set {
			print("SET")
			resultLegArray = newValue!
		}
		get {
			return resultLegArray
		}
	}
	var protocolSelectedIndex: Int? {
		set {
			print("SET")
			selectedIndex = newValue ?? 0
		}
		get {
			return selectedIndex
		}
	}
}

