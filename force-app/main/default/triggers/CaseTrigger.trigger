trigger CaseTrigger on Case (after insert) {

  if(Trigger.isInsert && Trigger.isAfter){
    CaseTriggerHandler.onAfterInsert(Trigger.new);
  }

}