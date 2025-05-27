//
//  PeripheralEntity.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/26/25.
//

import CoreBluetooth

public struct PeripheralEntity: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let peripheral: CBPeripheral
    public var isConnected: Bool = false
    /// 서비스별 특성을 관리하는 배열
    private(set) var serviceItems: [ServiceEntity] = []
    
    init(id: UUID, peripheral: CBPeripheral) {
        self.id = id
        self.peripheral = peripheral
    }
    
    // 서비스 목록을 설정하는 메서드
    public mutating func setService(_ services: [CBService]) {
        // 서비스 배열을 순회하며, 각 서비스에 해당하는 특성들을 매핑하여 ServiceItem 배열을 생성
        self.serviceItems = services.map { service in
            ServiceEntity(service: service, characteristics: [])
        }
    }
    
    // 특성 목록을 서비스별로 설정하는 메서드
    public mutating func setCharacteristics(for service: CBService, characteristics: [CBCharacteristic]) {
        if let index = serviceItems.firstIndex(where: { $0.service.uuid == service.uuid }) {
            serviceItems[index].characteristics = characteristics
            serviceItems[index].isValid = true
        }
    }
    
    // 특정 서비스에 포함된 특성들 가져오기
    public func characteristics(for service: CBService) -> [CBCharacteristic]? {
        return serviceItems.first { $0.service.uuid == service.uuid }?.characteristics
    }
    
    public var isAllValid: Bool {
        return serviceItems.allSatisfy({ $0.isValid })
    }
}


public struct ServiceEntity: Equatable, Hashable {
    public let service: CBService
    public var characteristics: [CBCharacteristic] = []
    public var isValid: Bool = false
}
