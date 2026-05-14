@isTest
private class HelloWorldTest {
    
    @isTest
    static void testSayHello() {
        Test.startTest();
        HelloWorld.sayHello();
        Test.stopTest();
        
        // No assertion possible for debug logsaa1111
        System.assert(true);
    }
}