public with sharing class DeviceAssignmentTriggerHandler {

    // BEFORE INSERT: blochează alocarea unui echipament care nu e Available
    public static void validateAvailability(List<Device_Assignment__c> newList) {
        Set<Id> deviceIds = new Set<Id>();
        for (Device_Assignment__c da : newList) {
            deviceIds.add(da.Device__c);
        }

        // un singur query, în afara buclei
        Map<Id, Device__c> devices = new Map<Id, Device__c>(
            [SELECT Id, Status__c FROM Device__c WHERE Id IN :deviceIds]
        );

        Set<Id> seenInBatch = new Set<Id>();
        for (Device_Assignment__c da : newList) {
            Device__c dev = devices.get(da.Device__c);
            if (dev != null && dev.Status__c != 'Available') {
                da.addError('Echipamentul nu este disponibil (status: ' + dev.Status__c + ').');
            } else if (!seenInBatch.add(da.Device__c)) {
                da.addError('Același echipament apare de mai multe ori în aceeași operațiune.');
            }
        }
    }

    // AFTER INSERT: echipamentul devine Assigned
    public static void markDevicesAssigned(List<Device_Assignment__c> newList) {
        Map<Id, Device__c> toUpdate = new Map<Id, Device__c>();
        for (Device_Assignment__c da : newList) {
            if (da.End_Date__c == null) {
                toUpdate.put(da.Device__c, new Device__c(Id = da.Device__c, Status__c = 'Assigned'));
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate.values();   // un singur DML
        }
    }

    // AFTER UPDATE: la returnare (End Date completat) echipamentul revine Available
    public static void markDevicesReturned(List<Device_Assignment__c> newList,
                                           Map<Id, Device_Assignment__c> oldMap) {
        Map<Id, Device__c> toUpdate = new Map<Id, Device__c>();
        for (Device_Assignment__c da : newList) {
            Device_Assignment__c oldDa = oldMap.get(da.Id);
            if (da.End_Date__c != null && oldDa.End_Date__c == null) {
                toUpdate.put(da.Device__c, new Device__c(Id = da.Device__c, Status__c = 'Available'));
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate.values();
        }
    }
}
