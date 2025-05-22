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
            VStack(spacing: 0.0) {
                NavigationLink(destination: {
                    CentralView()
                }, label: {
                    Text("중앙장치 테스트")
                })
            }
        }
        
    }
}

#Preview {
    ContentView()
}
