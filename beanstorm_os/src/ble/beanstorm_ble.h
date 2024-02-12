#pragma once

#include "NimBLEDevice.h"
#include "ble_callbacks.h"
#include "model.h"

class DataService
{
public:
private:
};

class BeanstormBLE
{
public:
    ~BeanstormBLE () = default;

    void Setup ();

    void ModelDidUpdate (const Model & model);

private:
    NimBLEServer * ble_server_;
    DescriptorCallbacks descriptor_callbacks_;
    CharacteristicCallbacks characteristic_callbacks_;

    static void BLEServiceTask (void * param);
    void StartBLEServiceTask ();
    NimBLEService * CreateBeanService ();
    NimBLEService * CreateDataService ();

    static const NimBLEUUID kBeanServiceUUID;
    static const NimBLEUUID kBeanCharacteristicUUID;

    static const NimBLEUUID kDataServiceUUID;
    static const NimBLEUUID kPressureCharacteristicUUID;
    static const NimBLEUUID kTemperatureCharacteristicUUID;
    static const NimBLEUUID kFlowCharacteristicUUID;
};
