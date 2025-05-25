//
//  CentralView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/22/25.
//

import SwiftUI

struct CentralView: View {
    @StateObject private var bleManager: BLECentralManager = BLECentralManager()
    
    @State private var selectedPeripheral: PeripheralItem?
    
    var body: some View {
        VStack(spacing: 0.0) {
            buttonsView
            peripheralsListView
        }
        .sheet(item: $selectedPeripheral) { selectedPeripheral in
            PeripheralDetailView(peripheralItem: selectedPeripheral)
        }
    }
}

extension CentralView {
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
            VStack {
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
                        Text("상세화면")
                            .onTapGesture {
                                selectedPeripheral = item
                            }
                    }
                }
                
                if item.isConnected {
                    textFieldsView
                }
            }
        }
    }
    
    private var textFieldsView: some View {
        VStack {
            VStack {
                Text("보낼 메시지 입력")
                TextField("입력하세요.", text: $bleManager.sendValue)
                    .onSubmit {
                        bleManager.writeData()
                    }
            }
            .padding()
            
            VStack {
                Text("받은 메시지 출력")
                Text(bleManager.receivedValue)
            }
            .padding()
        }
    }
}


#Preview {
    CentralView()
}
