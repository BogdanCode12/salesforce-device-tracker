trigger DeviceAssignmentTrigger on Device_Assignment__c (before insert, after insert, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        DeviceAssignmentTriggerHandler.validateAvailability(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        DeviceAssignmentTriggerHandler.markDevicesAssigned(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        DeviceAssignmentTriggerHandler.markDevicesReturned(Trigger.new, Trigger.oldMap);
    }
}
