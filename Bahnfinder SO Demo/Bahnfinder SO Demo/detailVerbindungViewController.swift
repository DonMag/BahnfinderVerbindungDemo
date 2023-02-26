//
//  detailVerbindungViewController.swift
//  MVG App
//
//  Created by Victor Lobe on 19.01.23.
//

import UIKit
import TripKit
import CoreLocation

protocol verbindungDetailProtocol: AnyObject {
    var protocolTripArray: [Trip]? { set get }
    var protocolLegArray: [[[Leg]]]? { set get }
    var protocolSelectedIndex: Int? { set get }
    var protocolRefreshContext: RefreshTripContext? {set get}
    
}

class detailVerbindungViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            // This function is normally executed by the ViewController before:
            let (request, result) = await provider.queryTrips(from: Location(id: "A=1@O=Ratzeburg@X=10740635@Y=53698214@U=80@L=8004952@B=1@p=1677095209@"), via: nil, to: Location(id: "A=1@O=Kaiserstraße, Neubiberg@X=11666920@Y=48075399@u=120@U=80@L=622352@"), date: Date())
            switch result {
            case .success(let context, let from, let via, let to, let trips, let messages):
                for (index, trip) in trips.enumerated() {
                    resultTripsArray.append(trip)
                    refreshContext = trip.refreshContext!
                    var tempLeg = [[Leg]]()
                    tempLeg.append(trip.legs)
                    resultLegArray.append(tempLeg)
                }
                
                let currentTime = Date()
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
                
                mainTableView.reloadData()
                
                
            default: break
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailVerbindungTableViewCell", for: indexPath) as! detailVerbindungTableViewCell
            
            for view in cell.contentView.subviews {
                if let label = view as? LineHalfTriangleView {
                    label.removeFromSuperview()
                }
            }
            for view in cell.sideLineView.subviews {
                cell.sideLineView.willRemoveSubview(view)
            }
            
            var arrayIndex = indexPath.row / 2
            print(arrayIndex)
            let middleSeperator = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.height / 2, width: cell.contentView.frame.width, height: 1))
            middleSeperator.backgroundColor = UIColor.systemBlue
            var sideLineType = "end"
            var sideColor = UIColor.clear
            var sideTopColor = UIColor.clear
            var sideBottomColor = UIColor.clear
            cell.devLabel.text = "\(arrayIndex)"
            cell.devLabel.isHidden = !UserDefaults.standard.bool(forKey: "devDetailVerbIndex")
            cell.lineNumberLabel.text = ""
            cell.lineNumberLabel.textColor = .label
            cell.lineNumberLabel.backgroundColor = .clear
            cell.intermediateStops.removeAll()
            cell.destinationLabel.text = ""
            cell.timeBottomLabel.text = ""
            cell.timeMiddleLabel.text = ""
            cell.timeTopLabel.text = ""
            cell.constDestToNumber.constant = 8
            cell.constDestToStrich.constant = 58
            cell.constDestToNumber.isActive = true
            cell.destinationLabel.font = UIFont.systemFont(ofSize: cell.destinationLabel.font.pointSize)
            cell.timeTopLabel.textColor = UIColor.label
            cell.timeMiddleLabel.textColor = UIColor.label
            cell.timeBottomLabel.textColor = UIColor.label
            cell.timeSeperatorView.isHidden = true
            cell.chevronImageView.isHidden = true

            if indexPath.row % 2 == 0 {
                //Location cell
                cell.contentView.backgroundColor = UIColor.systemBackground
                cell.constDestToNumber.isActive = false
                cell.constDestToStrich.constant = 8
                cell.destinationLabel.font = UIFont.systemFont(ofSize: cell.destinationLabel.font.pointSize, weight: .semibold)
                if arrayIndex == resultLegArray[selectedIndex][0].count {
                    cell.destinationLabel.text = resultLegArray[selectedIndex][0].last?.arrival.name
                } else {
                    cell.destinationLabel.text = resultLegArray[selectedIndex][0][arrayIndex].departure.name
                }
                if arrayIndex == resultLegArray[selectedIndex][0].count {
                    //Location cell
                    //Show Time
                    //Last cell
                    sideLineType = "end"
                    cell.timeTopLabel.isHidden = true
                    cell.timeMiddleLabel.isHidden = false
                    cell.timeBottomLabel.isHidden = true
                    if resultLegArray[selectedIndex][0].last is PublicLeg {
                        print("PublicLeg")
                        var tempPublicLeg = resultLegArray[selectedIndex][0].last as! PublicLeg
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
                        print("IndividualLeg")
                        var tempIndLeg = resultLegArray[selectedIndex][0].last as! IndividualLeg
                        cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempIndLeg.arrivalTime)
                        cell.timeMiddleLabel.textColor = UIColor.label
                        sideColor = UIColor.lightGray
                    }
                } else {
                    //Not last cell (here is first and every other cell)
                    //Location cell
                    //Show Time
                    if arrayIndex == 0 {
                        //first cell
                        sideLineType = "start"
                        cell.timeTopLabel.isHidden = true
                        cell.timeMiddleLabel.isHidden = false
                        cell.timeBottomLabel.isHidden = true
                        if resultLegArray[selectedIndex][0][arrayIndex] is PublicLeg {
                            print("PublicLeg")
                            var tempPublicLeg = resultLegArray[selectedIndex][0][arrayIndex] as! PublicLeg
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
                            print("IndividualLeg")
                            var tempIndLeg = resultLegArray[selectedIndex][0][arrayIndex] as! IndividualLeg
                            sideColor = UIColor.lightGray
                            cell.timeMiddleLabel.text = timeFormatHHMM.string(from: tempIndLeg.departureTime)
                            cell.timeMiddleLabel.textColor = UIColor.label
                        }
                    } else {//MARK: sideLineType Middle eg. every cell besiddes first and last
                        sideLineType = "middle"
                        cell.timeTopLabel.isHidden = false
                        cell.timeMiddleLabel.isHidden = true
                        cell.timeBottomLabel.isHidden = false
                        
                        if resultLegArray[selectedIndex][0][arrayIndex] is PublicLeg {
                            print("PublicLeg")
                            var tempPublicLeg = resultLegArray[selectedIndex][0][arrayIndex] as! PublicLeg

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
                            print("IndividualLeg")
                            var tempIndLeg = resultLegArray[selectedIndex][0][arrayIndex] as! IndividualLeg
                            sideBottomColor = UIColor.lightGray
                            cell.timeBottomLabel.text = timeFormatHHMM.string(from: tempIndLeg.departureTime)
                            cell.timeBottomLabel.textColor = UIColor.label
                        }
                        
                        
                        if resultLegArray[selectedIndex][0][arrayIndex-1] is PublicLeg { //Line before current
                            print("PublicLeg")
                            var tempPublicLeg = resultLegArray[selectedIndex][0][arrayIndex-1] as! PublicLeg
                            sideTopColor = UIColor(argb: tempPublicLeg.line.style.backgroundColor)
                            if tempPublicLeg.arrivalStop.predictedTime == nil {
                                cell.timeTopLabel.textColor = .label
                                cell.timeTopLabel.text = timeFormatHHMM.string(from: tempPublicLeg.arrivalStop.plannedTime)
                            } else if tempPublicLeg.arrivalStop.plannedTime == tempPublicLeg.arrivalStop.predictedTime {
                            cell.timeTopLabel.text = timeFormatHHMM.string(from: resultLegArray[selectedIndex][0][arrayIndex-1].arrivalTime)
                            cell.timeTopLabel.textColor = UIColor.systemGreen
                        } else {
                            let timeDifference = resultLegArray[selectedIndex][0][arrayIndex-1].plannedArrivalTime.distance(to: resultLegArray[selectedIndex][0][arrayIndex-1].arrivalTime )
                            cell.timeTopLabel.text = timeFormatHHMM.string(from: resultLegArray[selectedIndex][0][arrayIndex-1].arrivalTime)
                            cell.timeTopLabel.textColor = UIColor.systemRed
                            if timeDifference.stringFromTimeIntervalOnlyNumber().contains("-") == true {
                                cell.timeTopLabel.textColor = UIColor.systemBlue
                            }
                        }
                        } else {
                            print("IndividualLeg")
                            var tempIndLeg = resultLegArray[selectedIndex][0][arrayIndex-1] as! IndividualLeg
                            sideTopColor = UIColor.lightGray
                            cell.timeTopLabel.text = timeFormatHHMM.string(from: tempIndLeg.arrivalTime)
                            cell.timeTopLabel.textColor = UIColor.label
                        }
                    }
                }
                
                //Even index
            } else {
                //Info cell (Vehicle or Walk)
                cell.timeTopLabel.isHidden = true
                cell.timeMiddleLabel.isHidden = true
                cell.timeBottomLabel.isHidden = true
                sideLineType = "static"
                cell.backgroundColor = UIColor.systemBackground
                if resultLegArray[selectedIndex][0][arrayIndex] is PublicLeg {
                    //Fahrzeug
                    print("PublicLeg")
                    var tempPublicLeg = resultLegArray[selectedIndex][0][arrayIndex] as! PublicLeg
                    cell.lineNumberLabel.text = tempPublicLeg.line.label ?? ""
                    cell.destinationLabel.text = tempPublicLeg.destination?.name
                    if tempPublicLeg.line.style.backgroundColor2 == nil || tempPublicLeg.line.style.backgroundColor2 == 0 {
                        
                        cell.lineNumberLabel.backgroundColorC = tempPublicLeg.line.style.backgroundColor
                    } else {
                        cell.lineNumberLabel.backgroundColorC = UInt32(UIColor.clear.hexa)
                        let backgroundLineHalfHalf = LineHalfTriangleView(frame: cell.lineNumberLabel.frame)
                        backgroundLineHalfHalf.topColor = tempPublicLeg.line.style.backgroundColor
                        backgroundLineHalfHalf.bottomColor = tempPublicLeg.line.style.backgroundColor2
                        backgroundLineHalfHalf.borderColor = tempPublicLeg.line.style.borderColor
                        cell.contentView.addSubview(backgroundLineHalfHalf)
                        cell.contentView.sendSubviewToBack(backgroundLineHalfHalf)
                    }
                    cell.lineNumberLabel.shape = tempPublicLeg.line.style.shape
                    cell.lineNumberLabel.foregroundColor = tempPublicLeg.line.style.foregroundColor
                    cell.lineNumberLabel.borderColor = tempPublicLeg.line.style.borderColor
                    if tempPublicLeg.line.style.backgroundColor2 == nil || tempPublicLeg.line.style.backgroundColor2 == 0 {
                        cell.lineNumberLabel.backgroundColorC = tempPublicLeg.line.style.backgroundColor
                    } else {
                        cell.lineNumberLabel.backgroundColorC = UInt32(UIColor.clear.hexa)
                        let backgroundLineHalfHalf = LineHalfTriangleView(frame: cell.lineNumberLabel.frame)
                        backgroundLineHalfHalf.topColor = tempPublicLeg.line.style.backgroundColor
                        backgroundLineHalfHalf.bottomColor = tempPublicLeg.line.style.backgroundColor2
                        backgroundLineHalfHalf.borderColor = tempPublicLeg.line.style.borderColor
                        cell.contentView.addSubview(backgroundLineHalfHalf)
                        cell.contentView.sendSubviewToBack(backgroundLineHalfHalf)
                    }
                    //MARK: Info PublicLeg Time
                    if tempPublicLeg.departureTime == tempPublicLeg.plannedDepartureTime {
                        
                    } else {
                        let timeDifference = tempPublicLeg.plannedDepartureTime.distance(to: tempPublicLeg.departureTime )
                        cell.timeTopLabel.text = timeDifference.stringFromTimeIntervalWithText()
                        cell.timeTopLabel.textColor = UIColor.systemRed
                        cell.timeTopLabel.isHidden = false
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
                        cell.timeBottomLabel.isHidden = false
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
                    
                    let intermediateTableView = detailVerbindungIntermediateStopsTableView(frame: CGRect(x: 0, y: cell.frame.height, width: cell.frame.width, height: .zero))
                    intermediateTableView.translatesAutoresizingMaskIntoConstraints = false
                    intermediateTableView.register(detailVerbindungIntermediateStopTableViewCell.self, forCellReuseIdentifier: "detailVerbindungIntermediateStopTableViewCell")
                    intermediateTableView.dataSource = cell
                    intermediateTableView.delegate = cell
                    intermediateTableView.estimatedRowHeight = 20
                    intermediateTableView.rowHeight = 20
                    intermediateTableView.separatorInset.left = 96
                    cell.contentView.addSubview(intermediateTableView)
                    cell.intermediateStops = tempPublicLeg.intermediateStops
                    cell.sideColor = sideColor
                    if tempPublicLeg.intermediateStops.count == 0 {
                        cell.chevronImageView.isHidden = true
                    } else {
                        cell.chevronImageView.isHidden = false
                        if cell.frame.height > 72 {
                            cell.chevronImageView.image = UIImage(systemName: "chevron.up")
                        } else {
                            cell.chevronImageView.image = UIImage(systemName: "chevron.down")
                        }
                    }
                    
                    let bottomConstraint = NSLayoutConstraint(item: intermediateTableView, attribute: .top, relatedBy: .equal, toItem: cell.destinationLabel, attribute: .bottom, multiplier: 1.0, constant: 0)
                    let leadingConstraint = NSLayoutConstraint(item: intermediateTableView, attribute: .leading, relatedBy: .equal, toItem: cell.contentView, attribute: .leading, multiplier: 1.0, constant: 0)
                    let trailingConstraint = NSLayoutConstraint(item: intermediateTableView, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailing, multiplier: 1.0, constant: 0)
                    let heightConstraint = NSLayoutConstraint(item: intermediateTableView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20)
                    cell.contentView.addConstraints([bottomConstraint, leadingConstraint, trailingConstraint, heightConstraint])
                    
                    
                } else {
                    //Walk
                    print("IndividualLeg")
                    var tempIndLeg = resultLegArray[selectedIndex][0][arrayIndex] as! IndividualLeg
                    cell.destinationLabel.text = "Fußweg: \(tempIndLeg.departure.getDistanceText(CLLocation(latitude: CLLocationDegrees(tempIndLeg.arrival.coord?.lat ?? 0)/1000000, longitude: CLLocationDegrees(tempIndLeg.arrival.coord?.lon ?? 0)/1000000)))"
                    let config = UIImage.SymbolConfiguration(paletteColors: [.label, .lightGray])
                    let walkIconImgView = UIImageView(frame: CGRect(x: 96, y: 24, width: 42, height: 42))
                    walkIconImgView.contentMode = .scaleAspectFit
                    walkIconImgView.image = UIImage(systemName: "figure.walk.diamond")!.applyingSymbolConfiguration(config)
                    cell.addSubview(walkIconImgView)
                    walkIconImgView.isHidden = true
                    let imageAttachment = NSTextAttachment()
                    imageAttachment.image = UIImage(systemName: "figure.walk", withConfiguration: config)
                    let fullString = NSMutableAttributedString(string: "")
                    fullString.append(NSAttributedString(attachment: imageAttachment))
                    cell.lineNumberLabel.attributedText = fullString
                    sideColor = UIColor.lightGray
                }
            }
            
            switch sideLineType {
            case "middle": // ⎡ Comes from bottom to top
                // Create the ⏐ UIView
                let leftView = UIView()
                leftView.frame = CGRect(x: 0, y: cell.sideLineView.frame.height / 2 + 7, width: 6, height: cell.sideLineView.frame.height / 2)
                leftView.backgroundColor = sideBottomColor
                // Create the ⎯ UIView
                let rightView = UIView()
                rightView.frame = CGRect(x: 0, y: cell.sideLineView.frame.height / 2 + 7, width: cell.sideLineView.frame.width, height: 6)
                rightView.backgroundColor = sideBottomColor
                // Add the subviews to the container view
                cell.sideLineView.addSubview(leftView)
                cell.sideLineView.addSubview(rightView)
                // ⎣ Comes from top to bottom
                // Create the ⏐ UIView
                let topLeftView = UIView()
                topLeftView.frame = CGRect(x: 0, y: 0, width: 6, height: cell.sideLineView.frame.height / 2 - 11)
                topLeftView.backgroundColor = sideTopColor
                // Create the ⎯ UIView
                let topRightView = UIView()
                topRightView.frame = CGRect(x: 0, y: cell.sideLineView.frame.height / 2 - 11, width: cell.sideLineView.frame.width, height: 6)
                topRightView.backgroundColor = sideTopColor
                // Add the subviews to the container view
                cell.sideLineView.addSubview(topLeftView)
                cell.sideLineView.addSubview(topRightView)
            case "start": // ⎡
                let sideLineMainView = UIView(frame: CGRect(x: 0, y: cell.sideLineView.frame.height / 2 - 3, width: 6, height: cell.sideLineView.frame.height))
                sideLineMainView.backgroundColor = sideColor
                cell.sideLineView.addSubview(sideLineMainView)
                let sideLineSideView = UIView(frame: CGRect(x: 0, y: cell.sideLineView.frame.height / 2 - 3, width: cell.sideLineView.frame.width, height: 6))
                sideLineSideView.backgroundColor = sideColor
                cell.sideLineView.addSubview(sideLineSideView)
            case "end": // ⎣
                let sideLineMainView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: cell.sideLineView.frame.height / 2 + 3))
                sideLineMainView.backgroundColor = sideColor
                cell.sideLineView.addSubview(sideLineMainView)
                let sideLineSideView = UIView(frame: CGRect(x: 0, y: cell.sideLineView.frame.height / 2 - 3, width: cell.sideLineView.frame.width, height: 6))
                sideLineSideView.backgroundColor = sideColor
                cell.sideLineView.addSubview(sideLineSideView)
            case "static": // ⎥
                let sideLineMainView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: cell.sideLineView.frame.height))
                sideLineMainView.backgroundColor = sideColor
                cell.sideLineView.addSubview(sideLineMainView)
                
            default: break
            }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row / 2 >= resultLegArray[selectedIndex][0].count {
            return
        }
        
        if resultLegArray[selectedIndex][0][indexPath.row / 2] is PublicLeg && indexPath.row % 2 != 0 {
            if expandedRowIndex == indexPath.row {
                expandedRowIndex = -1
            } else {
                expandedRowIndex = indexPath.row
                
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    
    
    
    
}
extension detailVerbindungViewController: verbindungDetailProtocol {
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

