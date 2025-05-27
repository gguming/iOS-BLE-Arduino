//
//  ScanUseCase.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public final class ScanUseCase {
    private let centralRepository: CentralRepositoryProtocol
    
    public init(centralRepository: CentralRepositoryProtocol) {
        self.centralRepository = centralRepository
    }
}

extension ScanUseCase: ScanUseCaseProtocol {
    public func startScan(_ services: [CBUUID]?) -> AsyncStream<PeripheralEntity> {
        return centralRepository.scanForPeripherals(withServices: services)
    }
    
    public func stopScan() {
        centralRepository.stopScan()
    }
}
