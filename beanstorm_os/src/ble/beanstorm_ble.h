#pragma once

#include "NimBLEDevice.h"
#include "ble_callbacks.h"
#include "data_service.h"

#include <memory>

class BeanstormBLE
{
public:
    explicit BeanstormBLE (DataService & data_service);
    ~BeanstormBLE () = default;
    void Setup ();

private:
    static constexpr int kServiceIntervalMs = 100;

    DataService & data_service_;
    NimBLEServer * ble_server_ = nullptr;
    DescriptorCallbacks descriptor_callbacks_;
    CharacteristicCallbacks characteristic_callbacks_;

    static void BLEServiceTask (void * param);
    void StartBLEServiceTask ();
    NimBLEService * CreateBeanService ();

    static const NimBLEUUID kBeanServiceUUID;
    static const NimBLEUUID kBeanCharacteristicUUID;
};
