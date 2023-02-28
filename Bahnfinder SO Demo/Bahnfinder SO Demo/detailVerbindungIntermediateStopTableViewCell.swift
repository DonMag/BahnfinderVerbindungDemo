//
//  detailVerbindungIntermediateStopTableViewCell.swift
//  MVG App
//
//  Created by Victor Lobe on 22.01.23.
//

import UIKit

class detailVerbindungIntermediateStopTableViewCell: UITableViewCell {

    let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let stopLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func setupUI() {
            self.addSubview(timeLabel)
            NSLayoutConstraint.activate([
                timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                timeLabel.widthAnchor.constraint(equalToConstant: 46),
            ])
            
            self.addSubview(lineImageView)
            NSLayoutConstraint.activate([
                lineImageView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
                lineImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                lineImageView.widthAnchor.constraint(equalToConstant: 14),
                lineImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            self.addSubview(stopLabel)
            NSLayoutConstraint.activate([
                stopLabel.leadingAnchor.constraint(equalTo: lineImageView.trailingAnchor, constant: 8),
                stopLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
                stopLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                stopLabel.heightAnchor.constraint(equalToConstant: 20)
            ])
        self.addSubview(rightLabel)
        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            rightLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightLabel.heightAnchor.constraint(equalToConstant: 20)
            
        ])
        }


}
