//
//  ContentView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager: BLECentralManager = BLECentralManager()
    var body: some View {
        NavigationStack{
            VStack(spacing: 0.0) {
                buttonsView
                peripheralsListView
            }
            .navigationDestination(for: PeripheralItem.self) { item in
                PeripheralDetailView(peripheralItem: item)
            }
        }
        
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
        List(bleManager.discoveredPeripherals, id: \.id) { item in
            HStack {
                VStack(spacing: 0.0) {
                    Text(item.peripheral.name ?? "이름 없음")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(item.id.uuidString)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {
                        if item.isConnected {
                            bleManager.disconnect(item.peripheral)
                        } else {
                            bleManager.connect(item.peripheral)
                        }
                    }, label: {
                        Text(item.isConnected ? "연결완료" : "연결")
                    })
                }
                if item.isConnected {
                    NavigationLink("상세화면", value: item)
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
