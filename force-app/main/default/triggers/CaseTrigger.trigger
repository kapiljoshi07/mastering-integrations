trigger CaseTrigger on Case (after insert, after update) {

  if(Trigger.isInsert && Trigger.isAfter){
    CaseTriggerHandler.onAfterInsert(Trigger.new);
  }

  if(Trigger.isUpdate && Trigger.isAfter){
    CaseTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
  }

}