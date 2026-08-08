import 'dart:async';
import 'dart:convert';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:flutter/foundation.dart';

import 'ble_constants.dart';
import 'rack_sensor_data.dart';
import 'sensor_simulator.dart';

// logica
// logica
// logica
// logica
// logica
// logica
class BleServer {
  final SensorSimulator simulator;
  bool _advertising = false;
  String? _connectedDeviceId;
  final List<StreamSubscription> _subs = [];
  Function(String)? onConfigReceived;

  BleServer(this.simulator);

  bool get isAdvertising => _advertising;

  // logica
  Uint8List _floatToBytes(double value) {
    final data = ByteData(4);
    data.setFloat32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Uint8List _byteToBytes(int value) {
    return Uint8List.fromList([value & 0xFF]);
  }

  Future<void> startAdvertising() async {
    try {
      await BlePeripheral.initialize();

      await BlePeripheral.addService(
        BleService(
          uuid: BleConstants.serviceUUID,
          primary: true,
          characteristics: [
            _char(BleConstants.temperatureUUID),
            _char(BleConstants.humidityUUID),
            _char(BleConstants.powerUUID),
            _char(BleConstants.doorUUID),
            _char(BleConstants.alertUUID),
            BleCharacteristic(
              uuid: BleConstants.configUUID,
              properties: [CharacteristicProperties.write.index, CharacteristicProperties.writeWithoutResponse.index],
              permissions: [AttributePermissions.writeable.index],
              value: null,
            ),
          ],
        ),
      );

      BlePeripheral.setWriteRequestCallback((deviceId, characteristicId, offset, value) {
        if (characteristicId.toLowerCase() == BleConstants.configUUID.toLowerCase() && value != null) {
          final configStr = utf8.decode(value);
          debugPrint('[BleServer] Configuracion recibida: $configStr');
          onConfigReceived?.call(configStr);
        }
        return null;
      });

      // logica
      BlePeripheral.setConnectionStateChangeCallback(
        (String deviceId, bool connected) {
          if (connected) {
            _connectedDeviceId = deviceId;
            debugPrint('[BleServer] Telefono conectado: $deviceId');
          } else {
            _connectedDeviceId = null;
            debugPrint('[BleServer] Telefono desconectado');
          }
        },
      );

      await BlePeripheral.startAdvertising(
        services: [BleConstants.serviceUUID],
        localName: BleConstants.deviceName,
      );

      _advertising = true;
      debugPrint('[BleServer] Advertising iniciado. Esperando conexion...');

      // logica
      // logica
      _subs.add(simulator.dataStream.listen((RackSensorData d) {
        _notify(BleConstants.temperatureUUID, _floatToBytes(d.temperature));
        _notify(BleConstants.humidityUUID, _byteToBytes(d.humidity));
        _notify(BleConstants.powerUUID, _floatToBytes(d.power));
        _notify(BleConstants.doorUUID, Uint8List.fromList(utf8.encode(d.door)));
        _notify(BleConstants.alertUUID, _byteToBytes(d.alert));
      }));
    } catch (e) {
      _advertising = false;
      debugPrint('[BleServer] Error: $e');
      rethrow;
    }
  }

  BleCharacteristic _char(String uuid) {
    return BleCharacteristic(
      uuid: uuid,
      properties: [
        CharacteristicProperties.read.index,
        CharacteristicProperties.notify.index,
      ],
      permissions: [AttributePermissions.readable.index],
      value: null,
    );
  }

  void _notify(String uuid, Uint8List value) {
    final deviceId = _connectedDeviceId;
    if (deviceId == null) return;
    BlePeripheral.updateCharacteristic(
      characteristicId: uuid,
      value: value,
      deviceId: deviceId,
    ).catchError((e) => debugPrint('[BleServer] Error NOTIFY $uuid: $e'));
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
