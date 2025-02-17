import { LightningElement, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWorkPlanUnits from '@salesforce/apex/WorkPlanUnitTreeController.getWorkPlanUnits';
import getWorkPlanUnit from '@salesforce/apex/WorkPlanUnitTreeController.getWorkPlanUnit';
import CampaignId from '@salesforce/schema/Opportunity.CampaignId';

export default class WorkPlanUnitTree extends LightningElement {
    @api campaignId = '';
    @api requireCampaignId = false;
    workPlanUnits;
    error;
    selectedWorkPlan = { name: '', label: '' };
    displaySubmit = true;
    hasData = false;

    @wire(getWorkPlanUnits, { campaignId: '$campaignId' } )
    wiredWorkPlanUnits({ error, data }) {
        this.hasData = false;
        if (data) {
            this.workPlanUnits = data;
            this.hasData = (data.length > 0);
            this.error = undefined;
        } else if (error) {
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            console.log('ERROR: '+this.error)

            this.error = error;
            this.workPlanUnits = undefined;
        }
    }

    connectedCallback() {
        if (this.requireCampaignId && this.campaignId == null) {
            const errorEvent = new CustomEvent('error', {
                detail: { message: 'You must select a campaign' }
            });
            this.dispatchEvent(errorEvent);
        }
    }

    handleSelect(e) {
        this.selectedWorkPlan = { name: e.detail.name, label: e.detail.label };
    }

    @api handleSubmit() {
        let rec;

        if (this.selectedWorkPlan.name === '') {
            this.displayToastErrorMessage('Please select a Funding Priority');
            return;
        }

        getWorkPlanUnit( { workplanunitId: this.selectedWorkPlan.name } )
        .then(result => {
            if (result) {
                rec = result;
                if (rec.RecordType.DeveloperName == 'Funding_Priority_Level_1') {
                    this.displayToastErrorMessage('Level 1 cannot be selected');
                } else {
                    const selectedEvent = new CustomEvent('workplanselected', {
                        detail: { name: rec.Id, label: rec.Name }
                    });
                    this.dispatchEvent(selectedEvent);
                }
            } else {
                this.displayToastErrorMessage('This level cannot be selected');
            }
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
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
}