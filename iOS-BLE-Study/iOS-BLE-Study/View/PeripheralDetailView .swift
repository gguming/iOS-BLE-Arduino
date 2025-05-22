//
//  PeripheralDetailView .swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/22/25.
//

import SwiftUI

struct PeripheralDetailView: View {
    var peripheralItem: PeripheralItem
    var body: some View {
        VStack {
            if peripheralItem.serviceItems.isEmpty {
                Text("No services available.")
            } else {
                List {
                    ForEach(peripheralItem.serviceItems, id: \.self) { serviceItem in
                        Section(header: Text("Service: \(serviceItem.service.uuid.uuidString)")) {
                            ForEach(serviceItem.characteristics, id: \.uuid) { characteristic in
                                VStack(alignment: .leading) {
                                    Text("Characteristic: \(characteristic.uuid.uuidString)")
                                        .font(.headline)
                                    
//                                    Text("Properties: \(characteristic.properties.description)")
//                                        .font(.subheadline)
                                    
                                    // 특성 권한 표시
                                    if characteristic.properties.contains(.read) {
                                        Text("Readable")
                                    }
                                    if characteristic.properties.contains(.write) {
                                        Text("Writable")
                                    }
                                    if characteristic.properties.contains(.notify) {
                                        Text("Notifiable")
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
        }
    }
}
