import { LightningElement, wire, api } from 'lwc';
import getBeatAlerts from '@salesforce/apex/BeatEventAlertController.getBeatAlerts'
import getCMT from '@salesforce/apex/BeatEventAlertController.getCMT'
import { refreshApex } from '@salesforce/apex';

export default class BeatEventAlert extends LightningElement {
    @api wiredRecords;
    @api cmtRecord;
    @api isLoading;
    refreshVal;

    connectedCallback(){
        this.refreshComponent();
    }

    @wire(getBeatAlerts) 
    wiredAlerts(value){
        this.refreshVal = value;
        if(value.data) {
            this.wiredRecords = value.data;
        }
        else if(value.error) {
            console.log(value.error);
        }
    }

    @wire(getCMT) 
    wiredCMT({ error, data}){
        if(data) {
            this.cmtRecord = JSON.parse(JSON.stringify(data));
        }
        else if(error) {
            console.log(error);
        }
    }

    refreshComponent(){
        this.isLoading = true;
        refreshApex(this.refreshVal)
        .then(() => {
            setTimeout(() => {
                this.isLoading = false
            }, 750);
        })
        .catch(() => {
            setTimeout(() => {
                this.isLoading = false
            }, 750);
        })
    }
}