@isTest
public with sharing class KnowledgeCategoryPickerTest {
    @isTest
    public static void testGetValues() {
        Test.startTest();
        KnowledgeCategoryPicker picker = new KnowledgeCategoryPicker();
        VisualEditor.DynamicPickListRows values = picker.getValues();
        Test.stopTest();
        System.assert(values.size() > 0, 'We didn\'t find any Data Categories');
    }
    @isTest
    public static void testGetDefaultValues() {
        Test.startTest();
        KnowledgeCategoryPicker picker = new KnowledgeCategoryPicker();
        VisualEditor.DataRow value = picker.getDefaultValue();
        Test.stopTest();
        System.assertNotEquals(null, value.getLabel(), 'The Data Row\'s Label is null');
        System.assertNotEquals(null, value.getValue(), 'The Data Row\'s Value is null');
    }
}