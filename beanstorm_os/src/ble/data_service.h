#pragma once

#include <NimBLEDevice.h>
#include <atomic>
#include <event_bridge/event_bridge.h>
#include <peripherals/peripherals.h>

class DataService
{
public:
    explicit DataService (EventBridge & event_bridge);
    void Setup (NimBLEServer * ble_server);
    void Advertise (NimBLEAdvertising * advertising);

    void SensorStateUpdated (const Peripherals::SensorState & sensor_state);
    void HeaterPIDUpdated (const PIDConstants & pid_constants);

    void Service ();

private:
    class ShotControlCallbacks final : public NimBLECharacteristicCallbacks
    {
    public:
        explicit ShotControlCallbacks (EventBridge & event_bridge);
        ~ShotControlCallbacks () override = default;

        void onWrite (NimBLECharacteristic * characteristic) override;

    private:
        EventBridge & event_bridge_;
    };

    class PIDCallbacks final : public NimBLECharacteristicCallbacks
    {
    public:
        explicit PIDCallbacks () = default;
        ~PIDCallbacks () override = default;

        void onWrite (NimBLECharacteristic * characteristic) override;

        std::function<void (const PIDConstants &)> OnPIDValueUpdated;
    };

    void CreateHeaterPIDCharacteristic ();

    EventBridge & event_bridge_;
    NimBLEServer * ble_server_ = nullptr;
    NimBLEService * data_service_ = nullptr;

    ShotControlCallbacks shot_control_callbacks_ {event_bridge_};
    PIDCallbacks heater_pid_callbacks_;

    NimBLECharacteristic * pressure_characteristic_ = nullptr;
    NimBLECharacteristic * temperature_characteristic_ = nullptr;
    NimBLECharacteristic * flow_characteristic_ = nullptr;
    NimBLECharacteristic * shot_control_characteristic_ = nullptr;
    NimBLECharacteristic * heater_pid_characteristic_ = nullptr;

    std::atomic<float> pressure_ {0.f};
    std::atomic<float> temperature_ {0.f};
    std::atomic<float> flow_ {0.f};

    static const NimBLEUUID kDataServiceUUID;
    static const NimBLEUUID kPressureCharacteristicUUID;
    static const NimBLEUUID kTemperatureCharacteristicUUID;
    static const NimBLEUUID kFlowCharacteristicUUID;
    static const NimBLEUUID kShotControlCharacteristicUUID;
    static const NimBLEUUID kHeaterPIDCharacteristicUUID;
};
