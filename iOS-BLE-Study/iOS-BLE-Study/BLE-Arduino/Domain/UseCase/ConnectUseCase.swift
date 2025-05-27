//
//  ConnectUseCase.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public final class ConnectUseCase {
    private let centralRepository: CentralRepositoryProtocol
    
    public init(centralRepository: CentralRepositoryProtocol) {
        self.centralRepository = centralRepository
    }
}

extension ConnectUseCase: ConnectUseCaseProtocol {
    public func connect(to peripheral: CBPeripheral) async throws -> PeripheralEntity {
        try await centralRepository.connect(to: peripheral)
    }
    
    public func disconnect(from peripheral: CBPeripheral) async throws -> UUID {
        try await centralRepository.disconnect(from: peripheral)
    }
    
    
}
