#include "beanstorm_ble.h"

const NimBLEUUID BeanstormBLE::kBeanServiceUUID =
    NimBLEUUID ("2b998408-4b17-4fd9-ac0e-b92138c78f94");

const NimBLEUUID BeanstormBLE::kBeanCharacteristicUUID =
    NimBLEUUID ("e5384f14-9eda-4033-bcac-4a90b71fc628");

const NimBLEUUID BeanstormBLE::kDataServiceUUID =
    NimBLEUUID ("8ec57513-faca-4a5c-9a45-912bd28ce1dc");

const NimBLEUUID BeanstormBLE::kPressureCharacteristicUUID =
    NimBLEUUID ("46851b87-ee86-42eb-9e35-aaee0cad5485");

void BeanstormBLE::Setup ()
{
    NimBLEDevice::init ("BeanstormOS");
    NimBLEDevice::setPower (ESP_PWR_LVL_P9);
    NimBLEDevice::setSecurityAuth (BLE_SM_PAIR_AUTHREQ_SC);

    ble_server_ = NimBLEDevice::createServer ();
    ble_server_->setCallbacks (new ServerCallbacks ());

    auto bean_service = CreateBeanService ();
    bean_service->start ();

    auto data_service = CreateDataService ();
    data_service->start ();

    NimBLEAdvertising * advertising = NimBLEDevice::getAdvertising ();
    advertising->addServiceUUID (bean_service->getUUID ());
    advertising->addServiceUUID (data_service->getUUID ());

    advertising->setScanResponse (true);
    advertising->start ();

    Serial.println ("Advertising Started");
    StartBLEServiceTask ();
}

NimBLEService * BeanstormBLE::CreateDataService ()
{
    NimBLEService * data_service = ble_server_->createService (kDataServiceUUID);

    NimBLECharacteristic * pressure_characteristic = data_service->createCharacteristic (
        kPressureCharacteristicUUID, NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

    pressure_characteristic->setValue (20.0f);
    pressure_characteristic->setCallbacks (&characteristic_callbacks_);

    return data_service;
}

NimBLEService * BeanstormBLE::CreateBeanService ()
{
    NimBLEService * bean_service = ble_server_->createService (kBeanServiceUUID);

    NimBLECharacteristic * bean_characteristic = bean_service->createCharacteristic (
        kBeanCharacteristicUUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::NOTIFY);

    bean_characteristic->setValue ("Fries");
    bean_characteristic->setCallbacks (&characteristic_callbacks_);

    auto * bean_characteristic_2904 = (NimBLE2904 *) bean_characteristic->createDescriptor ("2904");
    bean_characteristic_2904->setFormat (NimBLE2904::FORMAT_UTF8);
    bean_characteristic_2904->setCallbacks (&descriptor_callbacks_);

    NimBLEDescriptor * cold_descriptor = bean_characteristic->createDescriptor (
        "C01D", NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_ENC, 20);
    cold_descriptor->setValue ("Send it back!");
    cold_descriptor->setCallbacks (&descriptor_callbacks_);

    return bean_service;
}

void BeanstormBLE::BLEServiceTask (void * param)
{
    auto beanstorm_ble = reinterpret_cast<BeanstormBLE *> (param);
    auto server = beanstorm_ble->ble_server_;

    for (;;)
    {
        if (server->getConnectedCount ())
        {
            NimBLEService * service = server->getServiceByUUID (kBeanServiceUUID);
            if (service)
            {
                NimBLECharacteristic * characteristic =
                    service->getCharacteristic (kBeanCharacteristicUUID);
                if (characteristic)
                {
                    characteristic->notify (true);
                }
            }
        }
        delay (2000);
    }

    vTaskDelete (NULL);
}

void BeanstormBLE::StartBLEServiceTask ()
{
    xTaskCreatePinnedToCore (BLEServiceTask,
                             "BLE Service Task",
                             4000,
                             this,
                             1,
                             nullptr,
                             CONFIG_BT_NIMBLE_PINNED_TO_CORE);
}

void BeanstormBLE::ModelDidUpdate (const Model & model)
{
}
