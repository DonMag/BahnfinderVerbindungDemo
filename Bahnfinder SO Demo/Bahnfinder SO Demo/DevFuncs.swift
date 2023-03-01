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

func loadFrom(_ fileName: String) -> [Trip]? {
	
	var trips: [Trip]!
	
	if let urlPath = Bundle.main.url(forResource: fileName, withExtension: "trips") {
		do {
			let data = try Data(contentsOf: urlPath)
			if let loadedArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Trip] {
				trips = loadedArray
			}
		} catch {
			print("Couldn't read file.")
		}
	}
	
//	let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
//
//	do {
//		let data = try Data(contentsOf: fullPath)
//		if let loadedArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Trip] {
//			trips = loadedArray
//		}
//	} catch {
//		print("Couldn't read file.")
//	}
	
	return trips
}
func convertAndSaveInDDPath (array:[Trip]) {

	let randomFilename = UUID().uuidString
	let fullPath = getDocumentsDirectory().appendingPathComponent(randomFilename)
	
	do {
		let data = try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
		try data.write(to: fullPath)
		print("saved:", fullPath)
	} catch {
		print("Couldn't write file")
	}
	
//	let encodedData = NSKeyedArchiver.archivedData(withRootObject: array)
//
//	print(encodedData.count)
	print()
	
//	let objCArray = NSMutableArray()
//	for obj in array {
//		// we have to do something like this as we can't store struct objects directly in NSMutableArray
//		let dict = NSDictionary(objects: [obj.firstName ?? "",obj.lastName ?? ""], forKeys: ["firstName" as NSCopying,"lastName" as NSCopying])
//		objCArray.add(dict)
//	}
//
//	// this line will save the array in document directory path.
//	objCArray.write(toFile: getFilePath(fileName: "patientsArray"), atomically: true)
}

