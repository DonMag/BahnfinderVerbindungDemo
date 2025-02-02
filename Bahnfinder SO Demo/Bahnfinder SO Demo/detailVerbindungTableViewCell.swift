//
//  detailVerbindungTableViewCell.swift
//  MVG App
//
//  Created by Victor Lobe on 19.01.23.
//

import UIKit
import TripKit

class detailVerbindungTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var sideLineView: UIView!
    @IBOutlet var lineNumberLabel: LineNumberLabel!
    @IBOutlet var timeTopLabel: UILabel!
    @IBOutlet var timeMiddleLabel: UILabel!
    @IBOutlet var timeBottomLabel: UILabel!
    @IBOutlet var destinationLabel: UILabel!
    @IBOutlet var constDestToStrich: NSLayoutConstraint!
    @IBOutlet var constDestToNumber: NSLayoutConstraint!
    @IBOutlet var devLabel: UILabel!
    @IBOutlet var timeSeperatorView: UIView!
    @IBOutlet var chevronImageView: UIImageView!
    
    var intermediateStops = [Stop]()
    var sideColor = UIColor()
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intermediateStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailVerbindungIntermediateStopTableViewCell", for: indexPath) as! detailVerbindungIntermediateStopTableViewCell
        cell.stopLabel.text = intermediateStops[indexPath.row].location.name
        if let time = intermediateStops[indexPath.row].departure?.time {
            cell.timeLabel.text = timeFormatHHMM.string(from: time)
        } else {
            cell.timeLabel.text = ""
        }
        let sideLineMainView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 20))
        sideLineMainView.backgroundColor = sideColor
        cell.lineImageView.addSubview(sideLineMainView)
        cell.rightLabel.isHidden = true
        
        if intermediateStops[indexPath.row].departure?.predictedTime == nil {
            //Keine Live
            cell.timeLabel.textColor = UIColor.label
            if let time = intermediateStops[indexPath.row].departure?.plannedTime {
                cell.timeLabel.text = timeFormatHHMM.string(from: time)
            } else {
                cell.timeLabel.text = ""
            }        } else {
            //Live
            if intermediateStops[indexPath.row].departure?.predictedTime == intermediateStops[indexPath.row].departure?.plannedTime {
                //Pünktlich
                cell.timeLabel.textColor = UIColor.systemGreen
                cell.timeLabel.text = timeFormatHHMM.string(from: intermediateStops[indexPath.row].departure!.plannedTime)
            } else {
                //Außerfahrplanmäßige Zeit
                let timeDifference = intermediateStops[indexPath.row].departure?.predictedTime?.timeIntervalSince(intermediateStops[indexPath.row].departure!.plannedTime)
                
                let delayAttString = NSMutableAttributedString()
                var delayString = NSAttributedString()
                var timeString = NSAttributedString()
                let firstKlammer = NSAttributedString(string: "(", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                let secondKlammer = NSAttributedString(string: ")", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                if timeDifference!.stringFromTimeIntervalWithText().contains("-") {
                    delayString = NSAttributedString(string: timeDifference!.stringFromTimeIntervalOnlyNumber(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
                    timeString = NSAttributedString(string: timeFormatHHMM.string(from: (intermediateStops[indexPath.row].departure?.predictedTime)!), attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
                    cell.timeLabel.textColor = .systemBlue
                } else {
                    delayString = NSAttributedString(string: "+\(timeDifference!.stringFromTimeIntervalOnlyNumber())", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
                    timeString = NSAttributedString(string: timeFormatHHMM.string(from: (intermediateStops[indexPath.row].departure?.predictedTime)!), attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
                    cell.timeLabel.textColor = .systemRed
                }
                delayAttString.append(firstKlammer)
                delayAttString.append(delayString)
                delayAttString.append(secondKlammer)
                cell.timeLabel.text = timeFormatHHMM.string(from: (intermediateStops[indexPath.row].departure?.predictedTime)!)
                cell.rightLabel.isHidden = false
                cell.rightLabel.attributedText = delayAttString
                
                
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
