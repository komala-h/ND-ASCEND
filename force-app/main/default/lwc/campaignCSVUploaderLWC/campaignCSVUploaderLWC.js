import { LightningElement, track, api } from 'lwc';

import saveFile from '@salesforce/apex/CampaignCSVUploaderController.saveFile';
import myResource from '@salesforce/resourceUrl/MassUploadCampaignAppeals';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'; 

const columns = [

   { label: 'Job Number', fieldName: 'nd_Job_Number__c' },

   { label: 'Channel', fieldName: 'ND_Channel__c' },

   { label: 'Campaign Name', fieldName: 'Name' },
  
   { label: 'Type', fieldName: 'Type' },

   { label: 'Parent Campaign', fieldName: 'ParentId' },
   { label: 'Default Designation', fieldName: 'nd_Default_Designation__c' },
   { label: 'StartDate', fieldName: 'StartDate' },
   { label: 'EndDate', fieldName: 'EndDate' },
   { label: 'Status', fieldName: 'Status' },
];

 

export default class CampaignCSVUploaderLWC extends LightningElement {

   @api recordid;

   @track columns = columns;

   @track data;

   @track fileName = '';

   @track UploadFile = 'Upload CSV File';

   @track showLoadingSpinner = false;

   @track isTrue = true;

   selectedRecords;

   filesUploaded = [];

   file;

   fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

 
   downloadCSV(){
    //alert(myResource);
    window.open(myResource,'_blank');
   }
 

   handleFilesChange(event) {

       if(event.target.files.length > 0) {

           this.filesUploaded = event.target.files;
           this.fileName = event.target.files[0].name;
           this.isTrue =false;
       }

   }

 

   handleSave() {

       if(this.filesUploaded.length > 0) {

           this.uploadHelper();

       }

       else {

           this.fileName = 'Please select a CSV file to upload!!';

       }

   }

 

   uploadHelper() {

       this.file = this.filesUploaded[0];

      /*if (this.file.size > this.MAX_FILE_SIZE) {

           window.console.log('File Size is to long');

           return ;

       }*/

       this.showLoadingSpinner = true;
       this.fileReader= new FileReader();
       this.fileReader.onloadend = (() => {
           this.fileContents = this.fileReader.result;
           this.saveToFile();
          
       });

       this.fileReader.readAsText(this.file);

   }

    
   saveToFile() {

       saveFile({ base64Data: JSON.stringify(this.fileContents)})

       .then(result => {

           window.console.log('result ====> ');
           window.console.log(result);
           this.data = result;

           this.fileName = this.fileName + ' - Uploaded Successfully';

           this.isTrue = true;

           this.showLoadingSpinner = false;

 

           this.dispatchEvent(

               new ShowToastEvent({

                   title: 'Success!!',

                   message: this.file.name + ' - Uploaded Successfully!!!',

                   variant: 'success',

               }),

           );

       })

       .catch(error => {

 
        this.showLoadingSpinner = false;
           window.console.log(error);

           this.dispatchEvent(

               new ShowToastEvent({

                   title: 'Error while uploading File',

                   message: error.message,

                   variant: 'error',

               }),

           );

       });

   }

 

}