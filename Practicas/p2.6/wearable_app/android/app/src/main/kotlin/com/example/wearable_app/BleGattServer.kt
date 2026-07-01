package com.example.wearable_app

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import java.util.UUID

class BleGattServer(private val context: Context) {
    companion object {
        private const val TAG = "BleGattServer"
        val SERVICE_UUID = UUID.fromString("12345678-1234-1234-1234-123456789abc")
        val STEPS_UUID = UUID.fromString("aaaaaaaa-0001-1234-1234-123456789abc")
        val HEART_RATE_UUID = UUID.fromString("aaaaaaaa-0002-1234-1234-123456789abc")
        val CALORIES_UUID = UUID.fromString("aaaaaaaa-0003-1234-1234-123456789abc")
        val STATUS_UUID = UUID.fromString("aaaaaaaa-0004-1234-1234-123456789abc")
    }

    private var bluetoothManager: BluetoothManager? = null
    private var gattServer: BluetoothGattServer? = null
    private var advertiseCallback: AdvertiseCallback? = null
    private var connectedDevice: BluetoothDevice? = null

    private val stepsChar: BluetoothGattCharacteristic
    private val heartRateChar: BluetoothGattCharacteristic
    private val caloriesChar: BluetoothGattCharacteristic
    private val statusChar: BluetoothGattCharacteristic

    private val serverCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            Log.d(TAG, "onConnectionStateChange: ${device?.address} state=$newState")
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevice = device
                Log.d(TAG, "Dispositivo conectado: ${device?.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedDevice = null
                Log.d(TAG, "Dispositivo desconectado")
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic?
        ) {
            Log.d(TAG, "onCharacteristicReadRequest: $characteristic")
            gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, characteristic?.value)
        }

        // Responder al CCCD write cuando el telefono llama setNotifyValue(true)
        override fun onDescriptorWriteRequest(
            device: BluetoothDevice?,
            requestId: Int,
            descriptor: BluetoothGattDescriptor?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            descriptor?.value = value
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
            Log.d(TAG, "CCCD write: ${descriptor?.uuid} responseNeeded=$responseNeeded")
        }
    }

    var onConnectionChange: ((Boolean) -> Unit)? = null

    init {
        val stepsChar = BluetoothGattCharacteristic(
            STEPS_UUID, 
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        stepsChar.addDescriptor(getClientCharacteristicConfigDescriptor())
        this.stepsChar = stepsChar

        val heartRateChar = BluetoothGattCharacteristic(
            HEART_RATE_UUID,
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        heartRateChar.addDescriptor(getClientCharacteristicConfigDescriptor())
        this.heartRateChar = heartRateChar

        val caloriesChar = BluetoothGattCharacteristic(
            CALORIES_UUID,
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        caloriesChar.addDescriptor(getClientCharacteristicConfigDescriptor())
        this.caloriesChar = caloriesChar

        val statusChar = BluetoothGattCharacteristic(
            STATUS_UUID,
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        statusChar.addDescriptor(getClientCharacteristicConfigDescriptor())
        this.statusChar = statusChar
    }

    private fun getClientCharacteristicConfigDescriptor(): BluetoothGattDescriptor {
        return BluetoothGattDescriptor(
            UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"),
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        ).apply {
            value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
        }
    }

    fun start(): Boolean {
        return try {
            bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            val adapter = bluetoothManager?.adapter ?: return false

            gattServer = bluetoothManager?.openGattServer(context, serverCallback)
            if (gattServer == null) {
                Log.e(TAG, "No se pudo crear GATT server")
                return false
            }

            val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
            service.addCharacteristic(stepsChar)
            service.addCharacteristic(heartRateChar)
            service.addCharacteristic(caloriesChar)
            service.addCharacteristic(statusChar)
            gattServer?.addService(service)

            startAdvertising(adapter)
            Log.d(TAG, "BLE GATT server iniciado correctamente")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error iniciando GATT server: ${e.message}")
            false
        }
    }

    private fun startAdvertising(adapter: BluetoothAdapter) {
        val advertiser = adapter.bluetoothLeAdvertiser ?: run {
            Log.w(TAG, "BLE advertiser no disponible")
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .build()

        // El paquete de advertising solo lleva el service UUID (128 bits = 18 bytes).
        // Incluir tambien el nombre del dispositivo excede el limite de 31 bytes y
        // provoca ADVERTISE_FAILED_DATA_TOO_LARGE (errorCode 1).
        val data = AdvertiseData.Builder()
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .setIncludeDeviceName(false)
            .build()

        // El nombre va en el scan response (segundo paquete de 31 bytes).
        val scanResponse = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()

        advertiseCallback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
                Log.d(TAG, "Advertising iniciado correctamente")
            }

            override fun onStartFailure(errorCode: Int) {
                Log.e(TAG, "Error advertising: $errorCode")
            }
        }

        advertiser.startAdvertising(settings, data, scanResponse, advertiseCallback)
    }

    fun notifySteps(value: Int) {
        val bytes = ByteArray(4)
        bytes[0] = (value and 0xFF).toByte()
        bytes[1] = ((value shr 8) and 0xFF).toByte()
        bytes[2] = ((value shr 16) and 0xFF).toByte()
        bytes[3] = ((value shr 24) and 0xFF).toByte()
        stepsChar.value = bytes
        notifyCharacteristic(stepsChar)
    }

    fun notifyHeartRate(value: Int) {
        heartRateChar.value = byteArrayOf(value.toByte())
        notifyCharacteristic(heartRateChar)
    }

    fun notifyCalories(value: Int) {
        val bytes = ByteArray(2)
        bytes[0] = (value and 0xFF).toByte()
        bytes[1] = ((value shr 8) and 0xFF).toByte()
        caloriesChar.value = bytes
        notifyCharacteristic(caloriesChar)
    }

    fun notifyStatus(value: String) {
        statusChar.value = value.toByteArray(Charsets.UTF_8)
        notifyCharacteristic(statusChar)
    }

    private fun notifyCharacteristic(char: BluetoothGattCharacteristic) {
        val device = connectedDevice ?: return
        try {
            gattServer?.notifyCharacteristicChanged(device, char, false)
        } catch (e: Exception) {
            Log.e(TAG, "Error notificando: ${e.message}")
        }
    }

    fun stop() {
        try {
            advertiseCallback?.let {
                val adapter = bluetoothManager?.adapter
                adapter?.bluetoothLeAdvertiser?.stopAdvertising(it)
            }
            gattServer?.clearServices()
            gattServer?.close()
            gattServer = null
            connectedDevice = null
            Log.d(TAG, "BLE GATT server detenido")
        } catch (e: Exception) {
            Log.e(TAG, "Error deteniendo GATT server: ${e.message}")
        }
    }
}
