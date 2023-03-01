//
//  Protocols.swift
//  Bahnfinder SO Demo
//
//  Created by Don Mag on 3/1/23.
//

import UIKit
import TripKit

protocol verbindungDetailProtocol: AnyObject {
	var protocolTripArray: [Trip]? { set get }
	var protocolLegArray: [[[Leg]]]? { set get }
	var protocolSelectedIndex: Int? { set get }
	var protocolRefreshContext: RefreshTripContext? {set get}
	
}

