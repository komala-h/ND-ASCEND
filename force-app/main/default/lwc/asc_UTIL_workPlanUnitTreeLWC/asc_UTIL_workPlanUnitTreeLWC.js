import { LightningElement, wire, api} from 'lwc';
import getWorkPlanUnits from '@salesforce/apex/asc_UTIL_FundingPriorityTreeController.getWorkPlanUnits';

export default class Asc_UTIL_workPlanUnitTreeLWC extends LightningElement {
    workPlanUnits;
    @api treeValue;
    error;

    @wire(getWorkPlanUnits)
    wiredContacts({ error, data }) {
        this.treeValue = 'Default';
        if (data) {
            this.workPlanUnits = data;
            this.error = undefined;
            // alert(JSON.stringify(data));
            // console.log('!!!' + JSON.stringify(data));
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

    handleOnselect(event) {

        this.treeValue = event.detail.name;
        
        var data = {'treeValue' : this.treeValue};
        const treeValueEvent = new CustomEvent("treevalueevent", {
            detail: { data }
        });
        // Fire the custom event
        this.dispatchEvent(treeValueEvent);
    }

}