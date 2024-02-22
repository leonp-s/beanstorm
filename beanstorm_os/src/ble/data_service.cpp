#include "data_service.h"

const NimBLEUUID DataService::kDataServiceUUID =
    NimBLEUUID ("8ec57513-faca-4a5c-9a45-912bd28ce1dc");

const NimBLEUUID DataService::kPressureCharacteristicUUID =
    NimBLEUUID ("46851b87-ee86-42eb-9e35-aaee0cad5485");

const NimBLEUUID DataService::kTemperatureCharacteristicUUID =
    NimBLEUUID ("76400bdc-15ce-4375-b861-97be9d54072c");

const NimBLEUUID DataService::kFlowCharacteristicUUID =
    NimBLEUUID ("13cdb71e-8d34-4d53-8f40-05d5677a48f3");

const NimBLEUUID DataService::kShotControlCharacteristicUUID =
    NimBLEUUID ("7e4881af-f9f6-4c12-bf5c-70509ba3d6b4");

DataService::DataService (EventBridge & event_bridge)
    : event_bridge_ (event_bridge)
{
}

DataService::ShotControlCallbacks::ShotControlCallbacks (EventBridge & event_bridge)
    : event_bridge_ (event_bridge)
{
}

void DataService::ShotControlCallbacks::onWrite (NimBLECharacteristic * characteristic)
{
    const bool shot_control_value = characteristic->getValue ();
    if (shot_control_value)
        event_bridge_.StartShot ();
    else
        event_bridge_.CancelShot ();
}

void DataService::Setup (NimBLEServer * ble_server)
{
    ble_server_ = ble_server;
    data_service_ = ble_server_->createService (kDataServiceUUID);

    pressure_characteristic_ = data_service_->createCharacteristic (
        kPressureCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    pressure_characteristic_->setValue (pressure_.load ());

    temperature_characteristic_ = data_service_->createCharacteristic (
        kTemperatureCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    temperature_characteristic_->setValue (temperature_.load ());

    flow_characteristic_ = data_service_->createCharacteristic (
        kFlowCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    flow_characteristic_->setValue (flow_.load ());

    shot_control_characteristic_ = data_service_->createCharacteristic (
        kShotControlCharacteristicUUID, NIMBLE_PROPERTY::WRITE);
    shot_control_characteristic_->setValue (false);
    shot_control_characteristic_->setCallbacks (&shot_control_callbacks_);

    data_service_->start ();
}

void DataService::Service ()
{
    pressure_characteristic_->setValue (pressure_.load ());
    temperature_characteristic_->setValue (temperature_.load ());
    flow_characteristic_->setValue (flow_.load ());

    pressure_characteristic_->notify ();
    temperature_characteristic_->notify ();
    flow_characteristic_->notify ();
}

void DataService::Advertise (NimBLEAdvertising * advertising)
{
    advertising->addServiceUUID (data_service_->getUUID ());
}

void DataService::SensorStateUpdated (const Peripherals::SensorState & sensor_state)
{
    pressure_.store (sensor_state.pressure > 0.0f ? sensor_state.pressure : 0.0f);
    temperature_.store (sensor_state.temperature);
    flow_.store (0.f);
}