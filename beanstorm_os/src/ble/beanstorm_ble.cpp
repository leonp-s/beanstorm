#include "beanstorm_ble.h"

void BeanstormBLE::Setup ()
{
    NimBLEDevice::init ("BeanstormOS");
    NimBLEDevice::setPower (ESP_PWR_LVL_P9);
    NimBLEDevice::setSecurityAuth (BLE_SM_PAIR_AUTHREQ_SC);

    ble_server_ = NimBLEDevice::createServer ();
    ble_server_->setCallbacks (new ServerCallbacks ());

    NimBLEService * pDeadService = ble_server_->createService ("DEAD");
    NimBLECharacteristic * pBeefCharacteristic = pDeadService->createCharacteristic (
        "BEEF",
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::READ_ENC |
            NIMBLE_PROPERTY::WRITE_ENC);

    pBeefCharacteristic->setValue ("Burger");
    pBeefCharacteristic->setCallbacks (&characteristic_callbacks_);

    NimBLE2904 * pBeef2904 = (NimBLE2904 *) pBeefCharacteristic->createDescriptor ("2904");
    pBeef2904->setFormat (NimBLE2904::FORMAT_UTF8);
    pBeef2904->setCallbacks (&descriptor_callbacks_);

    NimBLEService * pBaadService = ble_server_->createService ("BAAD");
    NimBLECharacteristic * pFoodCharacteristic = pBaadService->createCharacteristic (
        "F00D", NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::NOTIFY);

    pFoodCharacteristic->setValue ("Fries");
    pFoodCharacteristic->setCallbacks (&characteristic_callbacks_);

    NimBLEDescriptor * pC01Ddsc = pFoodCharacteristic->createDescriptor (
        "C01D",
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE |
            NIMBLE_PROPERTY::WRITE_ENC, // only allow writing if paired / encrypted
        20);
    pC01Ddsc->setValue ("Send it back!");
    pC01Ddsc->setCallbacks (&descriptor_callbacks_);

    pDeadService->start ();
    pBaadService->start ();

    NimBLEAdvertising * pAdvertising = NimBLEDevice::getAdvertising ();
    pAdvertising->addServiceUUID (pDeadService->getUUID ());
    pAdvertising->addServiceUUID (pBaadService->getUUID ());

    pAdvertising->setScanResponse (true);
    pAdvertising->start ();

    Serial.println ("Advertising Started");

    StartBLEServiceTask ();
}

void BeanstormBLE::BLEServiceTask (void * param)
{
    for (;;)
    {
        auto beanstorm_ble = reinterpret_cast<BeanstormBLE *> (param);
        if (beanstorm_ble->ble_server_->getConnectedCount ())
        {
            NimBLEService * pSvc = beanstorm_ble->ble_server_->getServiceByUUID ("BAAD");
            if (pSvc)
            {
                NimBLECharacteristic * pChr = pSvc->getCharacteristic ("F00D");
                if (pChr)
                {
                    pChr->notify (true);
                }
            }
        }
        delay (2000);
    }

    vTaskDelete (NULL);
}

void BeanstormBLE::StartBLEServiceTask ()
{
    xTaskCreate (BLEServiceTask, "BLE Service Task", 4000, this, 1, nullptr);
}

void BeanstormBLE::ModelDidUpdate (const Model & model)
{
}