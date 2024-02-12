#pragma once

#include "NimBLEDevice.h"
#include "ble_callbacks.h"

#include <atomic>
#include <peripherals/peripherals.h>

class DataService
{
public:
    void Setup (NimBLEServer * ble_server);
    void Advertise (NimBLEAdvertising * advertising);

    void SensorStateUpdated (const Peripherals::SensorState & sensor_state);
    void Service ();

private:
    NimBLEServer * ble_server_ = nullptr;
    CharacteristicCallbacks characteristic_callbacks_;

    NimBLEService * data_service_ = nullptr;

    NimBLECharacteristic * pressure_characteristic_ = nullptr;
    NimBLECharacteristic * temperature_characteristic_ = nullptr;
    NimBLECharacteristic * flow_characteristic_ = nullptr;

    std::atomic<float> pressure_ {0.f};
    std::atomic<float> temperature_ {0.f};
    std::atomic<float> flow_ {0.f};

    static const NimBLEUUID kDataServiceUUID;
    static const NimBLEUUID kPressureCharacteristicUUID;
    static const NimBLEUUID kTemperatureCharacteristicUUID;
    static const NimBLEUUID kFlowCharacteristicUUID;
};
