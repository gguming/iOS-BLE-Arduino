//
//  PeripheralItem.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import Foundation

struct PeripheralItem: Identifiable {
    let id: UUID
    let name: String
    
    init(id: UUID,
         name: String) {
        self.id = id
        self.name = name
    }
}
