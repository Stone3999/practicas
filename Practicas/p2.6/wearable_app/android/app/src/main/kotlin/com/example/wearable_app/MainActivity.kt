package com.example.wearable_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.wearable_app/ble_server"
        private const val REQUEST_BLUETOOTH_PERMISSIONS = 1001
    }

    private var bleGattServer: BleGattServer? = null
    private var pendingStartServer: Boolean = false

    private val bluetoothPermissions = arrayOf(
        Manifest.permission.BLUETOOTH_CONNECT,
        Manifest.permission.BLUETOOTH_SCAN,
        Manifest.permission.BLUETOOTH_ADVERTISE,
        Manifest.permission.ACCESS_FINE_LOCATION
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startServer" -> {
                    val success = startBleServer()
                    result.success(success)
                }
                "stopServer" -> {
                    stopBleServer()
                    result.success(true)
                }
                "notifySteps" -> {
                    val value = call.argument<Int>("value") ?: 0
                    bleGattServer?.notifySteps(value)
                    result.success(true)
                }
                "notifyHeartRate" -> {
                    val value = call.argument<Int>("value") ?: 0
                    bleGattServer?.notifyHeartRate(value)
                    result.success(true)
                }
                "notifyCalories" -> {
                    val value = call.argument<Int>("value") ?: 0
                    bleGattServer?.notifyCalories(value)
                    result.success(true)
                }
                "notifyStatus" -> {
                    val value = call.argument<String>("value") ?: ""
                    bleGattServer?.notifyStatus(value)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        requestBluetoothPermissions()
    }

    private fun requestBluetoothPermissions() {
        val needed = bluetoothPermissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), REQUEST_BLUETOOTH_PERMISSIONS)
        }
    }

    private fun startBleServer(): Boolean {
        if (!hasBluetoothPermissions()) {
            pendingStartServer = true
            requestBluetoothPermissions()
            return false
        }
        return doStartBleServer()
    }

    private fun hasBluetoothPermissions(): Boolean {
        return bluetoothPermissions.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun doStartBleServer(): Boolean {
        try {
            val adapter = BluetoothAdapter.getDefaultAdapter()
            if (adapter == null || !adapter.isEnabled) {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                startActivityForResult(enableBtIntent, REQUEST_BLUETOOTH_PERMISSIONS)
                return false
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error enabling BT: ${e.message}")
        }

        bleGattServer?.stop()
        bleGattServer = BleGattServer(this)
        val started = bleGattServer?.start() ?: false
        if (!started) {
            android.util.Log.e("MainActivity", "BLE GATT server failed to start")
        }
        return started
    }

    private fun stopBleServer() {
        bleGattServer?.stop()
        bleGattServer = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BLUETOOTH_PERMISSIONS && pendingStartServer) {
            pendingStartServer = false
            doStartBleServer()
        }
    }

    override fun onDestroy() {
        stopBleServer()
        super.onDestroy()
    }
}
