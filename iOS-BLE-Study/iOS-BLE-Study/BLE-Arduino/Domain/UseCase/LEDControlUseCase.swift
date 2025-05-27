//
//  LEDControlUseCase.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import CoreBluetooth

public final class LEDControlUseCase {
    private let centralRepository: CentralRepositoryProtocol
    
    public init(centralRepository: CentralRepositoryProtocol) {
        self.centralRepository = centralRepository
    }
}

extension LEDControlUseCase: LEDControlUseCaseProtocol {
    public func control(to peripheral: CBPeripheral, isOn: Bool, for characteristic: CBCharacteristic) async throws -> Bool {
        let converter = LEDData(isOn: isOn)
        let data = try converter.toBLEData()
        let result = try await centralRepository.writeDataWithResponse(value: data, to: peripheral, for: characteristic)
        if let first = result.first {
            return first == 1
        } else {
            return isOn
        }
    }
    
}
