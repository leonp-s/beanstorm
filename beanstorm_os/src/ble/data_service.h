#pragma once

#include "event_bridge/event_bridge.h"
#include "os_schema.h"
#include "peripherals/peripherals.h"

#include <NimBLEDevice.h>
#include <atomic>
#include <pb_decode.h>
#include <pb_encode.h>

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

    class BrewTransferCallbacks final : public NimBLECharacteristicCallbacks
    {
    public:
        explicit BrewTransferCallbacks (EventBridge & event_bridge);
        ~BrewTransferCallbacks () override = default;
        void onWrite (NimBLECharacteristic * characteristic) override;
        void onSubscribe (NimBLECharacteristic * pCharacteristic,
                          ble_gap_conn_desc * desc,
                          uint16_t subValue) override;

    private:
        static const std::string kEndOfFileFlag;
        EventBridge & event_bridge_;
        int bytes_received_ = 0;
        BrewProfileSchema brew_profile_schema_ {};
    };

    void CreateHeaterPIDCharacteristic ();
    void CreateBrewTransferCharacteristic ();

    EventBridge & event_bridge_;
    NimBLEServer * ble_server_ = nullptr;
    NimBLEService * data_service_ = nullptr;

    ShotControlCallbacks shot_control_callbacks_ {event_bridge_};
    PIDCallbacks heater_pid_callbacks_;
    BrewTransferCallbacks brew_transfer_callbacks_ {event_bridge_};

    NimBLECharacteristic * pressure_characteristic_ = nullptr;
    NimBLECharacteristic * temperature_characteristic_ = nullptr;
    NimBLECharacteristic * flow_characteristic_ = nullptr;
    NimBLECharacteristic * shot_control_characteristic_ = nullptr;
    NimBLECharacteristic * heater_pid_characteristic_ = nullptr;
    NimBLECharacteristic * brew_transfer_characteristic_ = nullptr;

    std::atomic<float> pressure_ {0.f};
    std::atomic<float> temperature_ {0.f};
    std::atomic<float> flow_ {0.f};

    static const NimBLEUUID kDataServiceUUID;
    static const NimBLEUUID kPressureCharacteristicUUID;
    static const NimBLEUUID kTemperatureCharacteristicUUID;
    static const NimBLEUUID kFlowCharacteristicUUID;
    static const NimBLEUUID kShotControlCharacteristicUUID;
    static const NimBLEUUID kHeaterPIDCharacteristicUUID;
    static const NimBLEUUID kBrewTransferCharacteristicUUID;
};
