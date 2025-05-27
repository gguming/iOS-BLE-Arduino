//
//  ContentView.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                NavigationLink(destination: {
                    CentralView()
                }, label: {
                    Text("중앙장치 테스트")
                })
                
                NavigationLink(destination: {
                    PeripheralView()
                }, label: {
                    Text("주변장치 테스트")
                })
                
                NavigationLink(destination: {
                    let repository = BLEArduinoManager()
                    let viewModel = ScanViewModel(scanUseCase: ScanUseCase(centralRepository: repository))
                    ScanView(viewModel: viewModel)
                }, label: {
                    Text("아두이노 연결")
                })
            }
        }
        
    }
}

#Preview {
    ContentView()
}
