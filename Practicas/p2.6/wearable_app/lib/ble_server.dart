import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ble_peripheral/ble_peripheral.dart';
import 'ble_constants.dart';
import 'sensor_simulator.dart';

class BleServer {
  final SensorSimulator simulator;
  bool _advertising = false;
  String? _connectedDeviceId;
  final List<StreamSubscription> _subs = [];

  BleServer(this.simulator);

  bool get isAdvertising => _advertising;

  Uint8List _intToBytes(int value) {
    final data = ByteData(4);
    data.setInt32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Uint8List _int16ToBytes(int value) {
    final data = ByteData(2);
    data.setInt16(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Future<void> startAdvertising() async {
    try {
      // Inicializar el modo periférico BLE
      await BlePeripheral.initialize();

      // Registrar el servicio GATT con las 4 características
      await BlePeripheral.addService(
        BleService(
          uuid: BleConstants.serviceUUID,
          primary: true,
          characteristics: [
            BleCharacteristic(
              uuid: BleConstants.stepsUUID,
              properties: [
                CharacteristicProperties.read.index,
                CharacteristicProperties.notify.index,
              ],
              permissions: [AttributePermissions.readable.index],
              value: null,
            ),
            BleCharacteristic(
              uuid: BleConstants.heartRateUUID,
              properties: [
                CharacteristicProperties.read.index,
                CharacteristicProperties.notify.index,
              ],
              permissions: [AttributePermissions.readable.index],
              value: null,
            ),
            BleCharacteristic(
              uuid: BleConstants.caloriesUUID,
              properties: [
                CharacteristicProperties.read.index,
                CharacteristicProperties.notify.index,
              ],
              permissions: [AttributePermissions.readable.index],
              value: null,
            ),
            BleCharacteristic(
              uuid: BleConstants.statusUUID,
              properties: [
                CharacteristicProperties.read.index,
                CharacteristicProperties.notify.index,
              ],
              permissions: [AttributePermissions.readable.index],
              value: null,
            ),
          ],
        ),
      );

      // Escuchar conexiones del teléfono
      BlePeripheral.setConnectionStateChangeCallback(
        (String deviceId, bool connected) {
          if (connected) {
            _connectedDeviceId = deviceId;
            print('[BleServer] Teléfono conectado: $deviceId');
          } else {
            _connectedDeviceId = null;
            print('[BleServer] Teléfono desconectado');
          }
        },
      );

      // Iniciar advertising con el UUID del servicio
      await BlePeripheral.startAdvertising(
        services: [BleConstants.serviceUUID],
        localName: 'WearOS',
      );

      _advertising = true;
      print('[BleServer] Advertising iniciado. Esperando conexión del teléfono...');

      // Suscribirse a los streams del simulador y enviar NOTIFY al teléfono
      _subs.add(simulator.stepsStream.listen(
        (steps) => _notify(BleConstants.stepsUUID, _intToBytes(steps)),
      ));
      _subs.add(simulator.heartRateStream.listen(
        (bpm) => _notify(BleConstants.heartRateUUID, Uint8List.fromList([bpm])),
      ));
      _subs.add(simulator.caloriesStream.listen(
        (cal) => _notify(BleConstants.caloriesUUID, _int16ToBytes(cal)),
      ));
      _subs.add(simulator.statusStream.listen(
        (status) => _notify(
          BleConstants.statusUUID,
          Uint8List.fromList(utf8.encode(status)),
        ),
      ));
    } catch (e) {
      _advertising = false;
      print('[BleServer] Error: $e');
      rethrow;
    }
  }

  void _notify(String uuid, Uint8List value) {
    final deviceId = _connectedDeviceId;
    if (deviceId == null) return;
    BlePeripheral.updateCharacteristic(
      characteristicId: uuid,
      value: value,
      deviceId: deviceId,
    ).catchError((e) => print('[BleServer] Error NOTIFY $uuid: $e'));
  }

  void stop() {
    _advertising = false;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _connectedDeviceId = null;
    BlePeripheral.stopAdvertising();
    simulator.stop();
  }
}
