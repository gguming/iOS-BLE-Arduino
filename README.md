# iOS-BLE-Arduino
# BLE 개발 내용 정리

## 주요 기능

- iOS 기기 끼리 서로 **BLE**로 연결하여 메시지를 주고 받을 수 있는 기능
- **Central**에서 **Peripheral**을 **scan**할 수 있는 기능
- 연결 되었을 경우 **Peripheral**의 **Service**, **Characteristic**, **Properties**를 확인할 수 있는 기능

## 현재 개발중인 기능

- **아두이노**를 연결하여 **LED 조작**, **온도 측정** 기능
- **클린 아키텍처** 적용
- **Concurrency** 적용

## 스펙

- **SwiftUI**, **CoreBluetooth** (BLE)

## 구동 이미지
<p align="left">
  <img src="https://github.com/user-attachments/assets/82d51dc6-a80b-4837-a44b-173797aeb252"  width="30%" height="30%"/>
  <img src="https://github.com/user-attachments/assets/ff6e6ab0-c474-42a7-931f-4ad534b6eb25"  width="30%" height="30%"/>
  <img src="https://github.com/user-attachments/assets/a96c105c-67c2-4c5a-8147-8c73f6846059"  width="30%" height="30%"/>
  <img src="https://github.com/user-attachments/assets/8708190f-af08-4769-83a5-a85143d4eed9"  width="50%" height="50%"/>
</p>

## 주요 학습 내용

- **BLE**에 대한 이론적인 학습과 실제 **Swift**에서의 구현 시 이론에 대한 내용이 어떻게 적용되어 있는지 확인
- 패킷 크기의 제한에 따른 메시지 전송은 어떻게 하는가?
    - 패킷을 보낼 때 **Byte** 단위로 통신을 하기 때문에 보낼 데이터에 대해 **MTU**를 계산하여 보낼 데이터를 슬라이스 해야 한다. 이때 **Data** 타입은 슬라이스를 하기 어렵기 때문에 **UInt8** 타입의 배열을 이용하여 데이터를 **MTU**에 맞게 자른 다음 순차적으로 보냄
- 패킷을 나누어 보내게 되었을 때 통신은 시리얼한가?
    - **시리얼하지 않음**. 그래서 데이터를 슬라이스해서 보낼 때 순서가 보장되도록 해주어야 하는데, **write**를 하느냐 **update**를 하느냐에 따라 대응 방식이 달라짐
    - **write**를 할 때는 보낼 때 응답을 받을지 말지에 대한 옵션이 있는데, 응답을 받는 옵션을 사용하면 순차적으로 보낼 수 있음
    - **update**를 할 때는 클라이언트에게 **notify**한 값을 보내고 나서 호출되는 `peripheralManagerIsReady(toUpdateSubscribers:)`를 이용하면 순차적으로 호출이 가능
- **Byte** 통신을 하다 보니 **ByteOrder**를 신경써야 한다. **BLE**의 공식 기준은 **Little Endian**, iOS도 **Little Endian**을 채택하고 있어 문제는 없지만, 종종 주변 장치에서 **Big Endian**을 쓰는 경우가 있어 주의해야 함

## 현재 개발중인 기능에 대한 고찰

1. **클린 아키텍처 적용**
    - 현재 구현한 기능은 **블루투스를 담당하는 Manager**가 편의를 위해 `ObservableObject`를 가지고 있는데, 결국 프로젝트가 커지고 아키텍처가 커지게 될 경우 독립적으로 있어야 된다고 판단되어 적용 중

2. **Concurrency 적용**
    - **Swift**의 변화 흐름에 맞춰 **Combine**보다 **Concurrency**를 도입하여 비동기 프로그래밍을 구현 중
    - 단순한 **delegate** 함수는 **Continuation**으로 비동기 이벤트 방출, 기능은 **AsyncStream**으로 구현
    - 하지만 **Discover**하는 과정이 정확히 어떤 타이밍에 작업이 완료되는지 추측은 가능하나, 정확한 확인이 어려워 작업 단위를 더 세분화해야 하는지 고민 중

3. **데이터 입출력 CRUD 추상화 적용**
    - 모든 특성에 맞춰 **Byte** 데이터를 바꾸는 코드를 **BLEManager**에 작성하는 것은 추후 유지보수에 좋지 않음
    - **Protocol**을 이용한 **DataConverter**를 만들고 전략 패턴을 사용하여 각 특성에 맞게 **Converter** 객체를 생성해 대응할 수 있도록 계획 중
