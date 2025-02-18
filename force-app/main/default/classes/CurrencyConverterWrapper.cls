public with sharing class CurrencyConverterWrapper {
    
    @AuraEnabled @InvocableVariable public String fromCode;
    @AuraEnabled @InvocableVariable public String toCode;
    @AuraEnabled @InvocableVariable public Double amount;

}