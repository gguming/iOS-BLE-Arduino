//
//  ArduinoUUID.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/25/25.
//

import CoreBluetooth

enum ArduinoUUID {
    static let ledService = CBUUID(string: "cd48409a-f3cc-11ed-a05b-0242ac120003")
    static let ledStatusCharacteristic = CBUUID(string:  "cd48409b-f3cc-11ed-a05b-0242ac120003")
    
    static let sensorService = CBUUID(string: "d888a9c2-f3cc-11ed-a05b-0242ac120003")
    static let temperatureCharacteristic = CBUUID(string:  "d888a9c3-f3cc-11ed-a05b-0242ac120003")
}
