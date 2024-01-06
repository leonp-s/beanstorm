#pragma once

#include "NimBLEDevice.h"
#include "ble_callbacks.h"
#include "model.h"

#include <memory>

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
};
