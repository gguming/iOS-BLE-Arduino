//
//  ScanView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import SwiftUI

struct ScanView: View {
    @StateObject var viewModel: ScanViewModel
    
    @State private var selectedPeripheral: PeripheralEntity?
    
    var body: some View {
        VStack {
            buttonsView
            peripheralsListView
        }
    }
}

extension ScanView {
    private var buttonsView: some View {
        HStack {
            Button(action: {
                viewModel.startScan()
            }, label: {
                Text("스캔 시작")
            })
            Spacer()
            Button(action: {
                viewModel.stopScan()
            }, label: {
                Text("스캔 종료")
            })
        }
        .padding()
    }
    
    private var peripheralsListView: some View {
        List(viewModel.discoveredPeripherals, id: \.id) { item in
            VStack {
                HStack {
                    VStack(spacing: 0.0) {
                        Text(item.peripheral.name ?? "이름 없음")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.id.uuidString)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    
}
