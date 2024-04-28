#include "data_service.h"

#include <cstring>

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

const NimBLEUUID DataService::kHeaterPIDCharacteristicUUID =
    NimBLEUUID ("ad94bdc2-8ea0-4282-aed8-47c4f917349b");

const NimBLEUUID DataService::kBrewTransferCharacteristicUUID =
    NimBLEUUID ("417249bc-3a8b-4958-8d44-d080eb48b890");

const std::string DataService::BrewTransferCallbacks::kEndOfFileFlag = "EOF";

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

void DataService::PIDCallbacks::onWrite (NimBLECharacteristic * characteristic)
{
    PIDSchema pid_schema {};
    const auto pid_value = characteristic->getValue ();
    memcpy (&pid_schema.buffer, pid_value.data (), sizeof (pid_schema.buffer));
    OnPIDValueUpdated (pid_schema.Decode ());
}

DataService::BrewTransferCallbacks::BrewTransferCallbacks (EventBridge & event_bridge)
    : event_bridge_ (event_bridge)
{
}

void DataService::BrewTransferCallbacks::onWrite (NimBLECharacteristic * characteristic)
{
    const auto chunk = characteristic->getValue ();
    auto chunk_size = chunk.size ();

    if (kEndOfFileFlag == chunk.c_str ())
    {
        // Do the parse and notify...
        std::unique_ptr<BrewProfile> brew_profile {new BrewProfile ()};
        brew_profile_schema_.Decode (*brew_profile, bytes_received_);

        Serial.print ("Decoded profile: ");
        Serial.println (brew_profile->uuid.c_str ());

        event_bridge_.OnBrewProfileUpdated (std::move (brew_profile));

        // Reset num bytes received
        bytes_received_ = 0;
    }
    else
    {
        Serial.print ("Chunk Received: ");
        Serial.println (bytes_received_);
        if (bytes_received_ < PBrewProfile_size)
            std::memcpy (&brew_profile_schema_.buffer [bytes_received_], chunk.data (), chunk_size);
        bytes_received_ += chunk_size;
    }

    characteristic->notify ();
}

void DataService::BrewTransferCallbacks::onSubscribe (NimBLECharacteristic * pCharacteristic,
                                                      ble_gap_conn_desc * desc,
                                                      uint16_t subValue)
{
    Serial.println ("Subscribed to brew transfer!");
    bytes_received_ = 0;
}

DataService::DataService (EventBridge & event_bridge)
    : event_bridge_ (event_bridge)
{
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

    CreateHeaterPIDCharacteristic ();
    CreateBrewTransferCharacteristic ();

    data_service_->start ();
}

void DataService::CreateHeaterPIDCharacteristic ()
{
    heater_pid_characteristic_ = data_service_->createCharacteristic (
        kHeaterPIDCharacteristicUUID,
        NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

    heater_pid_callbacks_.OnPIDValueUpdated = [&] (const PIDConstants & pid_constants)
    { event_bridge_.OnHeaterPIDUpdated (pid_constants); };
    heater_pid_characteristic_->setCallbacks (&heater_pid_callbacks_);
}

void DataService::CreateBrewTransferCharacteristic ()
{
    brew_transfer_characteristic_ = data_service_->createCharacteristic (
        kBrewTransferCharacteristicUUID,
        NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY |
            NIMBLE_PROPERTY::WRITE_NR);
    brew_transfer_characteristic_->setCallbacks (&brew_transfer_callbacks_);
}

void DataService::HeaterPIDUpdated (const PIDConstants & pid_constants)
{
    PIDSchema pid_schema {};
    if (pid_schema.Encode (pid_constants))
        heater_pid_characteristic_->setValue (pid_schema.buffer);
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
