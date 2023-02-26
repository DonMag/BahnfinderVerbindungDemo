//
//  detailVerbindungIntermediateStopsTableView.swift
//  Bahnfinder
//
//  Created by Victor Lobe on 07.02.23.
//

import UIKit

class detailVerbindungIntermediateStopsTableView: UITableView {

    override var intrinsicContentSize: CGSize {
      self.layoutIfNeeded()
      return self.contentSize
    }

    override var contentSize: CGSize {
      didSet{
        self.invalidateIntrinsicContentSize()
      }
    }

    override func reloadData() {
      super.reloadData()
      self.invalidateIntrinsicContentSize()
    }

}
