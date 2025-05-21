//
//  ContentView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager: BLEManager = BLEManager()
    var body: some View {
        NavigationView(content: {
            VStack(spacing: 0.0) {
                buttonsView
                peripheralsListView
            }
        })
    }
}

extension ContentView {
    private var buttonsView: some View {
        HStack {
            Button(action: {
                bleManager.retrievePeripheral()
            }, label: {
                Text("스캔 시작")
            })
            Spacer()
            Button(action: {
                bleManager.stopScanning()
            }, label: {
                Text("스캔 종료")
            })
        }
    }
    
    private var peripheralsListView: some View {
        List(bleManager.discoveredPeripherals, id: \.self) { peripheral in
            VStack(spacing: 0.0) {
                Text(peripheral.name ?? "이름 없음")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(peripheral.identifier.uuidString)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ContentView()
}
