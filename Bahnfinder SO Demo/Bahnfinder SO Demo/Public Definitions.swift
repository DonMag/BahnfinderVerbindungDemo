//
//  Public Definitions.swift
//  MVG App
//
//  Created by Victor Lobe on 05.01.23.
//

import Foundation
import UIKit

public let providerDB = "DB"
public let providerMVV = "MVV"
public let searchResultDestinationAbfahrten = "searchResultDestinationAbfahrten"
public let searchResultDestinationVerbindungFrom = "searchResultDestinationVerbindungFrom"
public let searchResultDestinationVerbindungTo = "searchResultDestinationVerbindungTo"
public let detailVerbindungCellTypeLocation = "detailVerbindungCellTypeLocation"
public let detailVerbindungCellTypeInfo = "detailVerbindungCellTypeInfo"

public struct searchStationObject: Codable, Equatable {
    let name: String
    let location: String
    let ID: String
    let provider: String
    var coords: String
}

public let timeFormatHHMM: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

public let timeFormatDHHMM: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M.d, HH:mm"
    return formatter
}()



public struct verbindungVerlaufObject: Codable, Equatable {
    let fromName: String
    let fromID: String
    let fromType: String
    let fromLocation: String
    let toName: String
    let toID: String
    let toType: String
    let toLocation: String
    let provider: String
}
