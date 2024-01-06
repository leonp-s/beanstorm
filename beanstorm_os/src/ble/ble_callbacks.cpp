#include "ble_callbacks.h"

void ServerCallbacks::onConnect (NimBLEServer * server)
{
    Serial.println ("Client connected");
    Serial.println ("Multi-connect support: start advertising");
    NimBLEDevice::startAdvertising ();
}

void ServerCallbacks::onConnect (NimBLEServer * server, ble_gap_conn_desc * desc)
{
    Serial.print ("Client address: ");
    Serial.println (NimBLEAddress (desc->peer_ota_addr).toString ().c_str ());
    server->updateConnParams (desc->conn_handle, 24, 48, 0, 60);
}

void ServerCallbacks::onDisconnect (NimBLEServer * server)
{
    Serial.println ("Client disconnected - start advertising");
    NimBLEDevice::startAdvertising ();
}

void ServerCallbacks::onMTUChange (uint16_t mtu, ble_gap_conn_desc * desc)
{
    Serial.printf ("mtu updated: %u for connection ID: %u\n", mtu, desc->conn_handle);
}

uint32_t ServerCallbacks::onPassKeyRequest ()
{
    Serial.println ("Server Passkey Request");
    return 123456;
}

bool ServerCallbacks::onConfirmPIN (uint32_t pass_key)
{
    Serial.print ("The passkey YES/NO number: ");
    Serial.println (pass_key);
    return true;
}

void ServerCallbacks::onAuthenticationComplete (ble_gap_conn_desc * desc)
{
    if (! desc->sec_state.encrypted)
    {
        NimBLEDevice::getServer ()->disconnect (desc->conn_handle);
        Serial.println ("Encrypt connection failed - disconnecting client");
        return;
    }
    Serial.println ("Starting BLE work!");
}

void CharacteristicCallbacks::onRead (NimBLECharacteristic * characteristic)
{
    Serial.print (characteristic->getUUID ().toString ().c_str ());
    Serial.print (": onRead(), value: ");
    Serial.println (characteristic->getValue ().c_str ());
}

void CharacteristicCallbacks::onWrite (NimBLECharacteristic * characteristic)
{
    Serial.print (characteristic->getUUID ().toString ().c_str ());
    Serial.print (": onWrite(), value: ");
    Serial.println (characteristic->getValue ().c_str ());
}

void CharacteristicCallbacks::onNotify (NimBLECharacteristic * characteristic)
{
    Serial.println ("Sending notification to clients");
}

void CharacteristicCallbacks::onStatus (NimBLECharacteristic * characteristic,
                                        Status status,
                                        int code)
{
    String str = ("Notification/Indication status code: ");
    str += status;
    str += ", return code: ";
    str += code;
    str += ", ";
    str += NimBLEUtils::returnCodeToString (code);
    Serial.println (str);
}

void CharacteristicCallbacks::onSubscribe (NimBLECharacteristic * characteristic,
                                           ble_gap_conn_desc * desc,
                                           uint16_t sub_value)
{
    String str = "Client ID: ";
    str += desc->conn_handle;
    str += " Address: ";
    str += std::string (NimBLEAddress (desc->peer_ota_addr)).c_str ();
    if (sub_value == 0)
    {
        str += " Unsubscribed to ";
    }
    else if (sub_value == 1)
    {
        str += " Subscribed to notfications for ";
    }
    else if (sub_value == 2)
    {
        str += " Subscribed to indications for ";
    }
    else if (sub_value == 3)
    {
        str += " Subscribed to notifications and indications for ";
    }
    str += std::string (characteristic->getUUID ()).c_str ();

    Serial.println (str);
}

void DescriptorCallbacks::onWrite (NimBLEDescriptor * descriptor)
{
    std::string dscVal = descriptor->getValue ();
    Serial.print ("Descriptor witten value:");
    Serial.println (dscVal.c_str ());
}

void DescriptorCallbacks::onRead (NimBLEDescriptor * descriptor)
{
    Serial.print (descriptor->getUUID ().toString ().c_str ());
    Serial.println ("Descriptor read");
}