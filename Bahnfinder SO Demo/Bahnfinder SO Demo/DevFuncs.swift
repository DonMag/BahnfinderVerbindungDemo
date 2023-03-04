//
//  DevFuncs.swift
//  Bahnfinder SO Demo
//
//  Created by Don Mag on 3/1/23.
//

import UIKit
import TripKit

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}

func saveTrips(tripsArray: [Trip]) {
		
	let fullPath = getDocumentsDirectory().appendingPathComponent("saved.trips")
	
	do {
		let data = try NSKeyedArchiver.archivedData(withRootObject: tripsArray, requiringSecureCoding: false)
		try data.write(to: fullPath)
		print("saved:", fullPath)
	} catch {
		print("Couldn't write file")
	}
	
}

func loadTripsFrom(url: URL) -> [Trip]? {

	var trips: [Trip]!
	
	do {
		let data = try Data(contentsOf: url)
		if let loadedArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Trip] {
			trips = loadedArray
		}
	} catch {
		print("Couldn't read file.")
	}

	return trips
	
}
