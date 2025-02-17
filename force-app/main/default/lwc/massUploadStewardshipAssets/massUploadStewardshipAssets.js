import { LightningElement,track,api } from 'lwc';
import saveFile from '@salesforce/apex/ND_massUploadStewardshipAssets.saveFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class MassUploadStewardshipAssets extends LightningElement {
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload CSV File';
    @track showLoadingSpinner = false;
    @track isFileUploaderDisabled = false;
    @track isComboboxDisabled = false;
    @track disableUploadCSVButton=true;
       
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    selectedValue;
    
    get picklistValues() {
        return [
            { label: 'Giving Society Acknowledgements', value: 'Giving_Society_Acknowledgements' },
            { label: 'Stewardship Item', value: 'Stewardship_Item' },
            { label: 'Membership Benefit', value: 'Membership_Benefit' },
        ];
    }

    handlePicklistChange(event) {
        
        this.selectedValue = event.detail.value;
        // Do something with the selected value
       
    }


    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.disableUploadCSVButton = false;
        }
        else{
            this.disableUploadCSVButton = true;
        }
    }
    
    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = 'Please select a CSV file to upload';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
           window.console.log('File Size is too long');
            return ;
        }
        this.showLoadingSpinner = true;
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            console.log('@@ file contents',this.fileContents);
            console.log('@@ json -->',JSON.stringify(this.fileContents));
            this.saveToFile();
        });
        this.fileReader.readAsText(this.file);
    }

    saveToFile() {
        saveFile({ base64Data: JSON.stringify(this.fileContents), recordtypeChosen: this.selectedValue})
        .then(result => {
            window.console.log('result => ');
            window.console.log(result);
            this.data = result;
            this.disableUploadCSVButton = true;
            this.showLoadingSpinner = false;    
            this.isFileUploaderDisabled = true;
            this.isComboboxDisabled = true;
 
            if(result == true) {
                this.fileName = this.fileName + ' - Uploaded Successfully';
                this.showToastMessage('Success',this.file.name + ' - has been submitted for batch job to process.You will recieve an email once it is complete', 'Success');
            }
            else{
                this.showToastMessage('Error','Error occured while uploading the file. Please check the input file', 'error');
            }
        })
 
        .catch(error => {
            window.console.log(error);
            this.showToastMessage('Error','Error occured while uploading the file', 'error');
        });
    }

    showToastMessage(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    close(){
		setTimeout(
			function() {
				window.history.back();
			},
			1000
		);
	}
}