//
//  ControlViewModel.swift
//  iOS-BLE-Study
//
//  Created by SUN on 5/27/25.
//

import Foundation

final class ControlViewModel: ObservableObject {
    private let connectUseCase: ConnectUseCaseProtocol
    private let ledControlUseCase: LEDControlUseCaseProtocol
    private var peripheralInfo: PeripheralEntity
    
    @Published var isOn: Bool = false
    
    init(connectUseCase: ConnectUseCaseProtocol,
         ledControlUseCase: LEDControlUseCaseProtocol,
         peripheralInfo: PeripheralEntity) {
        self.connectUseCase = connectUseCase
        self.ledControlUseCase = ledControlUseCase
        self.peripheralInfo = peripheralInfo
    }
}

extension ControlViewModel {
    func ledOn(isOn: Bool) {
        Task {
            do {
                if let characteristic = peripheralInfo.serviceItems.first(where: { $0.service.uuid == ArduinoUUID.ledService })?.characteristics.first(where: { $0.uuid == ArduinoUUID.ledStatusCharacteristic }) {
                    
                    let result = try await ledControlUseCase.control(to: peripheralInfo.peripheral,
                                                                     isOn: isOn,
                                                                     for: characteristic)
                    await MainActor.run {
                        self.isOn = result
                    }
                }
            } catch {
                self.isOn.toggle()
                print(error.localizedDescription)
            }
        }
    }
    func connect() {
        Task {
            do {
                let connectedPeripheral = try await connectUseCase.connect(to: peripheralInfo.peripheral)
                self.peripheralInfo = connectedPeripheral
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func disconnect() {
        Task {
            do {
                let disconnectedID = try await connectUseCase.disconnect(from: peripheralInfo.peripheral)
                self.peripheralInfo.isConnected = false
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
