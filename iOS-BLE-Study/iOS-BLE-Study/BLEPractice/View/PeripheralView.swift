//
//  PeripheralView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/23/25.
//

import SwiftUI

struct PeripheralView: View {
    @StateObject var blePeripheralManager = BLEPeripheralManager()
    @State private var isAdvertising: Bool = false
    
    var body: some View {
        VStack(spacing: 0.0) {
            buttonsView
            textFieldsView
            Spacer()
        }
    }
}

extension PeripheralView {
    private var buttonsView: some View {
        HStack {
            Toggle(isOn: $isAdvertising, label: {
                Text("Advetising")
            })
            .onChange(of: isAdvertising) {
                if isAdvertising {
                    blePeripheralManager.startAdvertising()
                } else {
                    blePeripheralManager.stopAdvertising()
                }
            }
        }
        .padding()
    }
    
    private var textFieldsView: some View {
        VStack(spacing: 0.0) {
            VStack {
                Text("내용")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("내용 입력하세요.",
                          text: $blePeripheralManager.textInput,
                          onEditingChanged: { _ in
                    isAdvertising = false
                })
            }
            .padding()
            
            VStack {
                Text("받은 내용")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(blePeripheralManager.receivedValue)
            }
            .padding()
            
        }
        .padding()
    }
}

#Preview {
    PeripheralView()
}
