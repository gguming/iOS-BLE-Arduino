//
//  PeripheralItem.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/21/25.
//

import CoreBluetooth

struct PeripheralItem: Identifiable, Equatable, Hashable {
    let id: UUID
    let peripheral: CBPeripheral
    var isConnected: Bool = false
    private(set) var serviceItems: [ServiceItem] = []  // 서비스별 특성을 관리하는 배열
    
    init(id: UUID, peripheral: CBPeripheral) {
        self.id = id
        self.peripheral = peripheral
    }
    
    // 서비스 목록을 설정하는 메서드
    mutating func setService(_ services: [CBService]) {
        // 서비스 배열을 순회하며, 각 서비스에 해당하는 특성들을 매핑하여 ServiceItem 배열을 생성
        self.serviceItems = services.map { service in
            ServiceItem(service: service, characteristics: [])
        }
    }
    
    // 특성 목록을 서비스별로 설정하는 메서드
    mutating func setCharacteristics(for service: CBService, characteristics: [CBCharacteristic]) {
        // 각 서비스에 해당하는 ServiceItem을 찾아서 특성을 설정
        if let index = serviceItems.firstIndex(where: { $0.service.uuid == service.uuid }) {
            serviceItems[index].characteristics = characteristics
        }
    }
    
    // 특정 서비스에 포함된 특성들 가져오기
    func characteristics(for service: CBService) -> [CBCharacteristic]? {
        return serviceItems.first { $0.service.uuid == service.uuid }?.characteristics
    }
}


struct ServiceItem: Equatable, Hashable {
    let service: CBService
    var characteristics: [CBCharacteristic] = []
}
