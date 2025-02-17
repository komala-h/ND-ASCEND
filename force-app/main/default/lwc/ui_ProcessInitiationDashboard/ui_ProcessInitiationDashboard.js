import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runExportBatch from '@salesforce/apex/ui_ProcessInitiationDashboardController.runProcess';

export default class ui_ProcessInitiationDashboard extends LightningElement {
    isLoading = false;

    handleButtonClick(event) {
        console.log(event.target.name);
        if (event.target.name === 'processNCOA') {
            this.initiateProcessInServer(event.target.name, null);
        }
    }

    initiateProcessInServer(processAPIName, params) {
        this.isLoading = true;
        runExportBatch({ batchToRun : processAPIName, params: params })
        .then((res => {
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Successfully scheduled the process initiation!',
                variant: 'success'
            });
            this.dispatchEvent(event);

        })).catch(error => {
            this.showErrorMessage('Failed to schedule the process Initiation. Error: ' + error.body.message)

        }).finally(() => {
            this.isLoading = false;
        });
    }

    showErrorMessage(errorMessage) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(event);  
    }
    
}