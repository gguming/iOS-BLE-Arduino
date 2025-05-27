//
//  ScanUseCaseProtocol.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public protocol ScanUseCaseProtocol {
    /// 스캔 시작
    /// - Parameter services: 조회할 services
    func startScan(_ services: [CBUUID]?) -> AsyncStream<PeripheralEntity>
    
    /// 스캔 종료
    func stopScan()
}
