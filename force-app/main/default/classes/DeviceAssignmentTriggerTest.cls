@isTest
private class DeviceAssignmentTriggerTest {

    @TestSetup
    static void setup() {
        insert new Contact(LastName = 'Test Employee');

        List<Device__c> devices = new List<Device__c>();
        for (Integer i = 0; i < 200; i++) {
            devices.add(new Device__c(
                Name = 'Device ' + i,
                Serial_Number__c = 'SN-T' + i,
                Type__c = 'Laptop',
                Status__c = 'Available'
            ));
        }
        insert devices;
    }

    private static Device__c getDevice(String serial) {
        return [SELECT Id, Status__c FROM Device__c WHERE Serial_Number__c = :serial];
    }
//Creează o alocare nouă pe un echipament Available.
    @isTest
    static void assignSetsStatusAssigned() {
        Contact emp = [SELECT Id FROM Contact LIMIT 1];
        Device__c dev = getDevice('SN-T0');

        Test.startTest();
        insert new Device_Assignment__c(Device__c = dev.Id, Employee__c = emp.Id, Start_Date__c = Date.today());
        Test.stopTest();

        Assert.areEqual('Assigned', getDevice('SN-T0').Status__c, 'Echipamentul trebuie să devină Assigned');
    }
//Alocă un echipament, apoi încearcă să-l aloce a doua oară.
    @isTest
    static void doubleAssignIsBlocked() {
        Contact emp = [SELECT Id FROM Contact LIMIT 1];
        Device__c dev = getDevice('SN-T1');
        insert new Device_Assignment__c(Device__c = dev.Id, Employee__c = emp.Id, Start_Date__c = Date.today());

        Test.startTest();
        Database.SaveResult sr = Database.insert(
            new Device_Assignment__c(Device__c = dev.Id, Employee__c = emp.Id, Start_Date__c = Date.today()),
            false
        );
        Test.stopTest();

        Assert.isFalse(sr.isSuccess(), 'A doua alocare trebuie blocată');
        Assert.isTrue(sr.getErrors()[0].getMessage().contains('nu este disponibil'));
    }
//Alocă un echipament, apoi completează End Date.
    @isTest
    static void returnSetsStatusAvailable() {
        Contact emp = [SELECT Id FROM Contact LIMIT 1];
        Device__c dev = getDevice('SN-T2');
        Device_Assignment__c da = new Device_Assignment__c(
            Device__c = dev.Id, Employee__c = emp.Id, Start_Date__c = Date.today().addDays(-3)
        );
        insert da;

        Test.startTest();
        update new Device_Assignment__c(Id = da.Id, End_Date__c = Date.today());
        Test.stopTest();

        Assert.areEqual('Available', getDevice('SN-T2').Status__c, 'După returnare trebuie să fie Available');
    }
//Creează 200 de alocări deodată, într-o singură operație.
    @isTest
    static void bulkAssign200() {
        Contact emp = [SELECT Id FROM Contact LIMIT 1];
        List<Device__c> devices = [SELECT Id FROM Device__c];
        List<Device_Assignment__c> assignments = new List<Device_Assignment__c>();
        for (Device__c d : devices) {
            assignments.add(new Device_Assignment__c(Device__c = d.Id, Employee__c = emp.Id, Start_Date__c = Date.today()));
        }

        Test.startTest();
        insert assignments;
        Test.stopTest();

        Integer assigned = [SELECT COUNT() FROM Device__c WHERE Status__c = 'Assigned'];
        Assert.areEqual(200, assigned, 'Toate cele 200 trebuie să fie Assigned');
    }
}
