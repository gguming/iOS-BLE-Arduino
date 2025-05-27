//
//  ControlView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import SwiftUI

struct ControlView: View {
    @StateObject var viewModel: ControlViewModel
    
    var body: some View {
        VStack {
            buttonsView
        }
        .onAppear {
            viewModel.connect()
        }
    }
}

extension ControlView {
    private var buttonsView: some View {
        HStack {
            Toggle("LED 조작", isOn: $viewModel.isOn)
        }
        .padding()
        .onChange(of: viewModel.isOn) {
            viewModel.ledOn(isOn: viewModel.isOn)
        }
    }
}
