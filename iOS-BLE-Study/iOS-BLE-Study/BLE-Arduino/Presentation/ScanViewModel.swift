//
//  ScanViewModel.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import Foundation

@MainActor
final class ScanViewModel: ObservableObject {
    private let scanUseCase: ScanUseCaseProtocol
    
    private var scanTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?
    
    @Published var discoveredPeripherals: [PeripheralEntity] = []
    
    init(scanUseCase: ScanUseCaseProtocol) {
        self.scanUseCase = scanUseCase
    }
}

extension ScanViewModel {
    
    func startScan() {
        scanTask?.cancel()
        scanTask = Task {
            for await peripheral in scanUseCase.startScan(nil) {
                if !discoveredPeripherals.contains(where: { $0.id == peripheral.id }) {
                    discoveredPeripherals.append(peripheral)
                }
            }
        }
    }
    
    func stopScan() {
        scanTask?.cancel()
        scanUseCase.stopScan()
    }
    
}
