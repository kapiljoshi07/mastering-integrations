public with sharing class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    
    public void handleResult(Metadata.DeployResult result,Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : 😍 '+ result);
        } else{
            System.debug(' fail : 🥵 '+ result);
        }
    }

    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        //Step 1: Create an instance of CustomMetadata object of Metadata namespace 
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();

        customMetadata.fullName = fullName;
        customMetadata.label = label;

        for(String key : fieldWithValuesMap.keySet()){
            // Step2 - Create the CustomMetadataValue Object from Metadata NameSpace
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key);
            customMetadata.values.add(customField);
        }

        //Step3 - Create the DeployContainer Object from Metadata NameSpace
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        
        //Step 4 - Add the metadata in the container
        container.addMetadata(customMetadata);

        //Step 5 - Deploy the metadata using operations 
        Id jobId = Metadata.Operations.enqueueDeployment(container, new CreateUpdateMetadataUtils());
    }
}