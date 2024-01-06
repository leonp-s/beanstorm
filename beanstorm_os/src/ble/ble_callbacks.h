#pragma once

#include "NimBLEDevice.h"

class ServerCallbacks : public NimBLEServerCallbacks
{
public:
    void onConnect (NimBLEServer * server) override;
    void onConnect (NimBLEServer * server, ble_gap_conn_desc * desc) override;
    void onDisconnect (NimBLEServer * server) override;
    void onMTUChange (uint16_t mtu, ble_gap_conn_desc * desc) override;
    uint32_t onPassKeyRequest () override;
    bool onConfirmPIN (uint32_t pass_key) override;
    void onAuthenticationComplete (ble_gap_conn_desc * desc) override;
};

class CharacteristicCallbacks : public NimBLECharacteristicCallbacks
{
    void onRead (NimBLECharacteristic * characteristic) override;
    void onWrite (NimBLECharacteristic * characteristic) override;
    void onNotify (NimBLECharacteristic * characteristic) override;
    void onStatus (NimBLECharacteristic * characteristic, Status status, int code) override;
    void onSubscribe (NimBLECharacteristic * characteristic,
                      ble_gap_conn_desc * desc,
                      uint16_t sub_value) override;
};

class DescriptorCallbacks : public NimBLEDescriptorCallbacks
{
public:
    void onWrite (NimBLEDescriptor * descriptor) override;
    void onRead (NimBLEDescriptor * descriptor) override;
};