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

const NimBLEUUID DataService::kBrewStateCharacteristicUUID =
    NimBLEUUID ("098ee759-8332-4492-8707-9d25875fe1a5");

const NimBLEUUID DataService::kIdleStateCharacteristicUUID =
    NimBLEUUID ("b15d2f31-3998-47fb-bf87-a73d302336cf");

const NimBLEUUID DataService::kProgramStateCharacteristicUUID =
    NimBLEUUID ("cd4bbb6a-1e17-4c5b-9e13-37f98cf2326d");

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
    const auto shot_control_value = characteristic->getValue ().data ();
    if (*shot_control_value == static_cast<uint8_t> (true))
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

    brew_state_characteristic_ = data_service_->createCharacteristic (
        kBrewStateCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    brew_state_characteristic_->setValue (flow_.load ());

    idle_state_characteristic_ = data_service_->createCharacteristic (
        kIdleStateCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    idle_state_characteristic_->setValue (flow_.load ());

    program_state_characteristic_ = data_service_->createCharacteristic (
        kProgramStateCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    program_state_characteristic_->setValue (flow_.load ());

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