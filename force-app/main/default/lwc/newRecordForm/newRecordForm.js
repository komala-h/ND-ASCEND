import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLayoutFromRecordType from '@salesforce/apex/NewRecordFormController.getLayoutFromRecordType';
import getLayoutFromObjectName from '@salesforce/apex/NewRecordFormController.getLayoutFromObjectName';
import getPageLayoutFields from '@salesforce/apex/NewRecordFormController.getPageLayoutFields';

export default class NewRecordForm extends LightningElement {
    @api objectName;
    @api recordTypeId;
    @api formLabel;
    layoutSections = [];
    layoutName;
    displayForm = false;
    btnFormSubmitDisabled = false;
    btnFormSubmitText = 'Save';

    loadPageLayout() {
        this.enableFormSubmitButton();
        
        if (this.recordTypeId != '') {
            getLayoutFromRecordType( { recordTypeId: this.recordTypeId } )
            .then(result => {
                if (result) {
                    this.layoutName = result;

                    getPageLayoutFields( { objectName: this.objectName, layoutName: this.layoutName } )
                    .then(result => {
                        if (result) {
                            this.displayForm = true;
                            this.layoutSections = result;
                        }
                    })
                    .catch(error => {
                        console.log('ERROR: '+JSON.stringify(error));
                    });
                }
            })
            .catch(error => {
                console.log('ERROR: '+JSON.stringify(error));
            });
        } else {
            getLayoutFromObjectName( { objectName: this.objectName } )
            .then(result => {
                if (result) {
                    this.layoutName = result;

                    getPageLayoutFields( { objectName: this.objectName, layoutName: this.layoutName } )
                    .then(result => {
                        if (result) {
                            this.displayForm = true;
                            this.layoutSections = result;
                        }
                    })
                    .catch(error => {
                        console.log('ERROR: '+JSON.stringify(error));
                    });
                }
            })
            .catch(error => {
                console.log('ERROR: '+JSON.stringify(error));
            });
        }
    }

    handleFormSubmit(e) {
        this.disableFormSubmitButton();

        let missingFields = [];

        let isValid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

        if (isValid) {
            isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
                return (validSoFar && field.reportValidity());
            }, true);
        }

        if (!isValid) {
            this.displayToastErrorMessage('Please complete the required fields');
            this.enableFormSubmitButton();
            return;
        } else {
            e.preventDefault();
            const fields = e.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleFormSuccess(e) {
        this.displayForm = false;
        this.enableFormSubmitButton();

        const recId = e.detail.id;

        const submitSuccess = new CustomEvent('newrecordsubmitsuccess', {
            detail: { name: recId }
        });
        this.dispatchEvent(submitSuccess);
    }

    handleFormError(e) {
        this.enableFormSubmitButton();
    }

    handleCloseForm() {
        this.displayForm = false;
    }

    disableFormSubmitButton() {
        this.btnFormSubmitDisabled = true;
        this.btnFormSubmitText = 'Saving...';
    }

    enableFormSubmitButton() {
        this.btnFormSubmitDisabled = false;
        this.btnFormSubmitText = 'Save';
    }

    displayToastErrorMessage(msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant: 'error'
            })
        );
    }

    @api showForm() {
        this.loadPageLayout();
    }
}