import { LightningElement,api,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord,getFieldDisplayValue } from 'lightning/uiRecordApi';

import { getObjectInfos,getPicklistValues } from 'lightning/uiObjectInfoApi';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Assignment_Object from '@salesforce/schema/ucinn_ascendv2__Assignment__c';
import  Account_Object from '@salesforce/schema/Account';
import AssignmentType_Field from '@salesforce/schema/ucinn_ascendv2__Assignment__c.ucinn_ascendv2__Assignment_Type__c';
import userDevCorFIELD from '@salesforce/schema/User.Development_Coordinator__c';
import userManagerFIELD from '@salesforce/schema/User.ManagerId';
import userNameFIELD from '@salesforce/schema/User.Name';
import getAccounts from '@salesforce/apex/ND_CustomLookupLwcController.getAccounts';
import saveToDB from '@salesforce/apex/ND_CustomLookupLwcController.saveResult';

import LightningAlert from 'lightning/alert'; 
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomDataTable extends NavigationMixin(LightningElement) {

    jsonStringList = [];
    disablePagination = true;
    sortBy;
    showDate = false;
    sortDirection;
    selRecordsCount=0;
    assTypeValue ='Primary Relationship Manager';
    initialRecords =[];
    @api tableHeader ='';
    MassAssTypeAdd = false;
    MassAssTypeDrop = false;
    orgHousehold= false;
    orgCorOrFoun = false;
    selOrgType='';
    selMassAssType='';
    selAssType='';
    typePrimary = false;
    typeSecondary=false;
    @api userId=Id;
    newSupervisior='';
    enableFundraiser= false;
    currentUserName = '';
    currentUserManagerIdEmail='';
    currentUserDevCoordinator='';
    assignmentDefaultRecordTypeId;
    orgHouseholdRecordType;
    orgCorporationRecordType;
    showTable= false;
    rows=[];
    errorMessage_0 =''
    validity_0 = true;
    validity_0_1 = false;
    isLoaded = false;   
    errorMessage_1 =''
    validity_1 = true;  
    validity_1_1 = false;  
    columnHeader =[];
    dataMap=[];
    count=0;
    searchKey ='';
    selectedRows = [];
    totalRecountCount=0;
    totalPage=0;
    currentPage=0;
    isPreviousDisable=true;
    isNextDisable=false;
    richTextLabel='Assignment Comments (to be applied to all new Assignments)';
    AssgComments='';
    NewAssgComments='';
    showpage1=true;
    disableSubmit=true;
    search

    @wire(getRecord, { recordId: '$userId', fields: [ userDevCorFIELD, userManagerFIELD, userNameFIELD]}) 
    currentUserInfo({error, data}) {
        if (data) {
            //alert(data.fields.Name.value);
            this.currentUserName = data.fields.Name.value;
            this.currentUserManagerIdEmail = data.fields.ManagerId.value;
            this.currentUserDevCoordinator = data.fields.Development_Coordinator__c.value;
            
        } else if (error) {
            //this.error = error ;
        }
    }    
    // to get the default record type id, if you dont' have any recordtypes then it will get master
    @wire(getObjectInfos, { objectApiNames: [Assignment_Object,Account_Object] })
    objectsInfo({error, data}){
    	if(data){
         //console.log('Hello:'+JSON.stringify(data.results));
         data.results.forEach(obj=>{
            let objName= obj.result.apiName;
            console.log(Object.values(obj.result));

            if(objName ==='ucinn_ascendv2__Assignment__c' ){
                this.assignmentDefaultRecordTypeId =obj.result.defaultRecordTypeId;
            }
            else if(objName ==='Account'){
                Object.values(obj.result.recordTypeInfos).forEach(recordTypeDetails=>{
                        console.log('RecordtypeName'+ JSON.stringify(recordTypeDetails));           
                        if(recordTypeDetails.name=='Corporations and Organizations Details'){
                            this.orgCorporationRecordType =recordTypeDetails.recordTypeId;
                        }else if(recordTypeDetails.name=='Household'){
                            this.orgHouseholdRecordType =recordTypeDetails.recordTypeId;
                        }                                          
                });
            }
         });
        }else{
         console.log(error);
        }
    }

    // now get the assignment picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '$assignmentDefaultRecordTypeId', 
            fieldApiName: AssignmentType_Field
        }
    )
    AssignmentTypePicklist;


    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.rows.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        this.selRecordsCount = this.selectedRows.length;
        console.log('Before selectedRows==> ' + JSON.stringify(this.selectedRows)+''+this.disableSubmit);
        if(this.selectedRows.length>0){
            this.disableSubmit = false;
        }else{
            this.disableSubmit = true;
        }
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows)+''+this.disableSubmit);
    }
    

    handleSelUser(event){
        //alert(event.detail.selectedRecord.Id);
        this.userId = event.detail.selectedRecord.Id;
    }
    handleNewFundraiser(event){
        this.newSupervisior =event.detail.selectedRecord.Id;
    }

    handleSubmit(event){
        this.isLoaded = true;
        let passedValidations = this.checkValBeforeSubmit();
        let otherParams={};
        
        if(passedValidations){
        
        otherParams.comments= this.AssgComments;
        otherParams.NewAssgComments = this.NewAssgComments;
        otherParams.newSupervisior = this.newSupervisior;
        otherParams.userId= this.userId;
        otherParams.selOrgType = this.selOrgType;
        otherParams.orgHouseholdRecordType = this.orgHouseholdRecordType;
        otherParams.orgCorporationRecordType = this.orgCorporationRecordType;
        otherParams.selAssType = this.selAssType;
        otherParams.enableFundraiser= this.enableFundraiser;
        otherParams.hc= this.hc;
        otherParams.ht= this.ht;
        otherParams.reEvalDate= this.reEvalDate;
        
        saveToDB({massAssType:this.selMassAssType,otherParams:JSON.stringify(otherParams),data:JSON.stringify(this.selectedRows)})
        .then(data => {
            console.log('Submit to Database');

            //alert('Submit'+data);
            this.showToast('The Assignment records have been successfully created for the selected Households','Request Processed','success');
            //this.navigateToAssignmentsRecentListView();
            //this.handleAlertSubmit(data,'Success!','success');
            this.isLoaded = false;   
            this.handleResetClick(event);
            
        })
        .catch(error => {
            console.log('error at submit()')
            console.log(error);
            this.isLoaded = false;
            //this.showToast(data,'Request Processed','success');
            this.handleAlertSubmit(error.body.message,'error','Something went wrong.','Error!');
        }) 
    }else{
        this.isLoaded = false;
        alert('Please fill required fields');

    }      

    }
    handleResetClick(event){
        this.count=0; 
        this.showDate = false;
        this.initialRecords=[];
        this.isLoaded = false;
        this.nextAccRef='';
        this.prevAccRef='';  
        this.massAssType='';
        this.showpage1= true; 
        this.orgHousehold = false;
        this.orgCorOrFoun = false;
        this.selAssType ='';   
        this.typePrimary =false;  
        this.typeSecondary=false;
        this.selOrgType='';
        this.MassAssTypeAdd = false;
        this.MassAssTypeDrop = false;
        this.showTable = false;
        this.enableFundraiser = false;
        this.dataMap=[];
        this.rows=[];
        this.columnHeader=[];
        this.selectedRows=[];
        this.disableSubmit= true;
        this.searchKey ='';
        this.jsonStringList =[];
        this.disablePagination = true;        
        this.navigateToAssignmentsRecentListView();
    }
    handleClick(event) {
        //this.clickedButtonLabel = event.target.label;
        this.isLoaded = true;
        this.count=0; 
        this.nextAccRef='';
        this.prevAccRef='';  
        //this.jsonStringList =[];
        
        // // addded file details: // new code
        // columns =[];
        // data = [];

        // const files = event.detail.files;
        // console.log("#### files = "+JSON.stringify(files));
        // if (files.length > 0) {
        //     const file = files[0];

        //     // start reading the uploaded csv file
        //     this.read(file);
        // }
        //     // new code end                 
        if(!this.checkVal()){
            alert('Please fill required fields');
            this.isLoaded = false;
        }else{
            
            this.callServerGetAccounts('','',this.selAssType,this.selOrgType,this.selMassAssType,'',this.jsonStringList);
            this.showpage1= false;
        } 





    //handleCSVUpload() {
        

    }

    columns =[];
    data = [];
    handleCSVUpload(event) {
        const files = event.detail.files;
        console.log("#### files = "+JSON.stringify(files));
        if (files.length > 0) {
            const file = files[0];

            // start reading the uploaded csv file
            this.read(file);
        }
    }

    async read(file) {
        try {
            const result = await this.load(file);
            //console.log("#### result = "+JSON.stringify(result));
            // execute the logic for parsing the uploaded csv file
            this.parseCSV(result);
        } catch (e) {
            this.error = e;
        }
    }

    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = () => {
                //console.log("#### reader.result = "+JSON.stringify(reader.result));
                resolve(reader.result);
            };
            reader.onerror = () => {
                //console.log("#### reader.error = "+JSON.stringify(reader.error));
                reject(reader.error);
            };
            //console.log("#### file = "+JSON.stringify(file));
            reader.readAsText(file);
        });
    }

    parseCSV(csv) {
        // parse the csv file and treat each line as one item of an array
      //  let jsonStringList = [];
        const lines = csv.split(/\r\n|\n/);
        console.log("#### lines = " + JSON.stringify(lines));
        // parse the first line containing the csv column headers
        const headers = lines[0].split(',');
        console.log("#### headers = " + JSON.stringify(headers));
    
        // iterate through csv headers and transform them to column format supported by the datatable
        this.columns = headers.map((header) => {
            return { label: header, fieldName: header };
        });
    
        const data = [];
    
        // iterate through csv file rows starting from index 1 to skip headers
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i];
            if (!line.trim()) continue; // Skip empty lines
            console.log("#### line = " + JSON.stringify(line));
            this.jsonStringList.push(JSON.stringify(line));
            const currentline = line.split(',');
            console.log("#### currentline = " + JSON.stringify(currentline));
            const obj = {};
    
            // Iterate through each header and assign corresponding value from current line
            for (let j = 0; j < headers.length; j++) {
                obj[headers[j]] = currentline[j];
            }
    
            data.push(obj);
    
            // Log values of the current object
            const values = Object.values(obj);
            console.log(`Values for row ${i}:`, values);
        }
    
        console.log("#### datalast = " + this.jsonStringList);
    
        // Assign the converted csv data for the lightning datatable
        this.data = data;
    }
    

// till here


    callServerGetAccounts(VarprevAccRef,VarnextAccRef,VarassType,varOrgType,varmassAssType,VarselIds,PrimeId){
        let rid =(this.orgHousehold?this.orgHouseholdRecordType: this.orgCorporationRecordType)
        getAccounts({ prevAccRef:VarprevAccRef,nextAccRef:VarnextAccRef,assType:VarassType,OrgType:varOrgType,massAssType:varmassAssType, recTypeId:rid,userId:this.userId ,PrimeIdList: PrimeId })
        .then(data => {
            this.isLoaded = false;
            if(data &&  Object.keys(data).length > 0){    
                console.log('data'+JSON.stringify(data));                
                this.showTable =true;
                this.totalRecountCount = data.recCount;
                this.totalPage = data.recCount>0 && data.recordsPerPage>0 ? Math.ceil(data.recCount/data.recordsPerPage):0;
                this.formatRecords (data.lstDataTableData,data.modifiedHeaders,data.tableMetaDataCrossObjInfo,VarselIds);
                this.columnHeader = data.lstDataTableColumns;
                if(this.selectedRows.length>0){
                    this.disableSubmit = false;
                }else{
                    this.disableSubmit = true;
                }                
                if(this.handleSearch!=null && this.handleSearch.length>0)
                this.handleSearch(null); 
       
            }else{
                if(VarselIds=='next'){
                    this.isNextDisable=true;
                }
                else if(VarselIds=='previous'){
                    this.isNextDisable=true;
                    
                }
            }
            if(this.rows.length==0)
            this.isNextDisable=true;
            else
            this.currentPage  =  1 +this.count; 
            //this.currentPage  =   this.dataMap.length; 
          
            
       
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('error at getAccounts()')
            console.log(error);
            this.handleAlertSubmit(error.body.message,'error','Something went wrong.','Error!:');
            //this.error = error;
            //this.accounts = undefined;
        })         
    }
    
    //press on previous button this method will be called
    handleNext() {  
        
        if(this.totalPage == this.currentPage){
            this.isNextDisable=false;       
        } 
        this.isLoaded = true;
        this.callServerGetAccounts('',this.dataMap[this.count].value[1],this.selAssType,this.selOrgType,this.selMassAssType,'next',null);
        

    }
    handlePrevious(){
        this.isLoaded = true;
        this.callServerGetAccounts(this.dataMap[this.count-1].value[0],this.dataMap[this.count].value[1],this.selAssType,this.selOrgType,this.selMassAssType,'previous',null); 
        
    }

    formatRecords(data,customheaders,datainfo,VarselIds){
        console.log('formatDat:'+ typeof data);
        if(data  &&  Object.keys(data).length > 0){
            console.log('formatDat:'+ typeof data);
            this.rows = [];
            this.rows =[... data];
            this.rows.forEach(item=>{
               let row= item;
                if(this.jsonStringList.length>0){
                    this.selectedRows.push(row.Id);
                    this.disablePagination = false;
                }
                
                console.log('New****',JSON.stringify(this.selectedRows));
                //console.log(JSON.stringify(row['Prospect_Region__c']));
                //console.log('check0',row.fields.Prospect_Region__c.displayValue);
               //console.log(row['ND_Group_Region__c']);
                if(customheaders){
                    Object.keys(customheaders).forEach(ckey=>{

                        if( customheaders[ckey] )
                            item[customheaders[ckey]]= '/'+item[ckey]; 
                         if(datainfo && typeof(datainfo[ckey]) !== "undefined" && datainfo[ckey]  !== null) {

                            let headers = datainfo[ckey];
                            let rowVal= headers['data'].split('.');
                            let rowLookup =  item[rowVal[0]];
                            item[headers['label']] = rowLookup[rowVal[1]];
                        }  

                    })                   
                }
                    
            });
            this.initialRecords = [...this.rows];
            let elements=[];
            console.log('21'+''+this.count);
            this.prevAccRef='';
            this.nextAccRef='';
            if(VarselIds =='previous')
                this.count--;
            if(VarselIds=='next' ) 
                this.count++;
            if(this.rows.length>0 && this.count>0){
                    
                this.isPreviousDisable=false;
            }

            console.log('count'+this.count);
            if(this.dataMap && !this.dataMap[this.count]){
                elements.push(this.rows[0].Id,  this.rows[this.rows.length-1].Id);
                this.dataMap.push({
                    key: this.count,
                    value: elements
                });
            } 
            console.log('next **** count'+this.count);
            if(this.count==0) {  
                this.isNextDisable=false;
                this.isPreviousDisable=true;
            }  
            //console.log(JSON.stringify(this.template.querySelector('[data-id="datatable"]')));
            if(this.jsonStringList.length==0)            
              this.disablePagination = true;

            this.selRecordsCount = this.selectedRows.length;
            //if(this.jsonStringList.length == 0 && this.selectedRows.length>0)
            //this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
        }

    }

    get enableAssType(){

        return this.orgHousehold && this.MassAssTypeAdd;
    }

    get options() {
        return [
            { label: 'Mass Add', value: 'Mass Add' },
            { label: 'Mass Drop', value: 'Mass Drop' }
        ];
    }

    get oraganizationOptions(){
        return [
            { label: 'Household', value: 'Household' },
            { label: 'Corporation or Foundation', value: 'Corporation or Foundation' }
        ];        
    }
    get assignmentOWnerOptions(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];        
    }
    /* Method validates all form fields before submiting the page actions*/

    checkVal() {       
    let isChildValidated = true;
    let isParentValid= true;
    [...this.template.querySelectorAll("c-custom-user-lookup")].forEach((element) => {
        
          if (element.isInputValid() === false) {
            isChildValidated = false;
          }
        });
      
    let inputFields = this.template.querySelectorAll('.validate');
    inputFields.forEach(inputField => {
        
                isParentValid = inputField.reportValidity();
        
    });
    return isChildValidated&&isParentValid;
    } 

    checkValBeforeSubmit() {       
        let isChildValidated = true;
        let isParentValid= true;
        let childCMp= [...this.template.querySelectorAll("c-custom-user-lookup")];
        if(childCMp){
        childCMp.forEach((element) => {
            
              if (element.isInputValid() === false) {
                isChildValidated = false;
              }
            });
          
        }
        
        let inputFields = this.template.querySelectorAll('.validate2');
        //console.log(JSON.stringify(inputFields) +''+inputFields.length);
        inputFields.forEach(inputField => {
                    if(isParentValid)
                        isParentValid = inputField.reportValidity();
                     else
                        inputField.reportValidity();   


        });
        
        if( this.enableFundraiser && this.NewAssgComments.length <= 0){
        this.validity_1 = false;
        this.validity_1_1 = true;
        this.errorMessage_1 = "Please enter the comments";
        isParentValid = false;
        console.log('richtext'+this.NewAssgComments.length);
        }else{
            this.validity_1 = true;
            this.validity_1_1 = false;
            this.errorMessage_1 = "";
        }

        if(this.AssgComments.length <= 0){
        this.validity_0 = false;
        this.validity_0_1 = true;
        isParentValid = false;
        this.errorMessage_0 = "Please enter the comments";
        }else{
            this.validity_0 = true;
            this.validity_0_1 = false;
            this.errorMessage_0 = "";
        }
        return isChildValidated && isParentValid;
    } 

    handleMassAssignmentTypeChange(event) {
        this.orgHousehold = false;
        this.orgCorOrFoun = false;
        this.selAssType ='';   
        this.typePrimary =false;  
        this.typeSecondary=false;
        this.selOrgType='';
        this.MassAssTypeAdd = false;
        this.MassAssTypeDrop = false;
        this.showTable = false;
        this.enableFundraiser = false;
        this.dataMap=[];


        this.selMassAssType= event.detail.value;
        if(event.detail.value=='Mass Add'){
            this.richTextLabel='Assignment Comments (to be applied to all new Assignments)';
            this.MassAssTypeAdd = true;
        }    
        if(event.detail.value=='Mass Drop') {
            this.richTextLabel='Assignment Comments for Dropped Assignments';       
            this.MassAssTypeDrop = true; 
        }  
        this.jsonStringList =[];
    }
    handleOrganizationTypeChange(event) {
        this.selOrgType =event.detail.value;
        this.orgHousehold = false;
        this.orgCorOrFoun = false;
        this.selAssType ='';   
        this.typePrimary =false;  
        this.typeSecondary=false;
        if(event.detail.value=='Household'){
            this.orgHousehold = true;
            this.selAssType = this.assTypeValue; 
            this.typePrimary = true;
        }
        if(event.detail.value=='Corporation or Foundation') {
            this.orgCorOrFoun = true;  
            this.selAssType = '';   
            this.typePrimary =false;          
        }     
    }

    handleAssignmentTypeChange(event) {
        this.selAssType =event.detail.value;   
        this.typePrimary= false;
        this.typeSecondary = false;
        if(event.detail.value =='Primary Relationship Manager'){
            this.typePrimary = true;
        }   
        if(event.detail.value=='Secondary Relationship Manager'){
            this.typeSecondary = true;
        }   
    }
    handleAssignmentOwnerChange(event){
        if(event.detail.value =='Yes')
            this.enableFundraiser= true;
        else   
            this.enableFundraiser= false; 
    }
    handleAssgComments(event){
        this.AssgComments =event.detail.value;
        if(this.AssgComments.length == 0){
            this.validity_0 = false;
            this.errorMessage_0 = "Please enter the comments";
        }
    }
    handleNewAssgComments(event){
        this.NewAssgComments =event.detail.value;

    }  
    handleDateChange(event){
        this.reEvalDate = event.detail.value;
    }  
    handleProspectChange(event){
        //alert(event.detail.value); 
        this.hc =event.detail.value; 
        if(this.hc =='LE')
            this.showDate = true;
        else
            this.showDate = false;
     
    }
    handleProspect2Change(event){
        //alert(event.detail.value);
        if(event.detail.value !='') 
            this.ht =event.detail.value;  
    }

    async handleAlertSubmit(msg,label,theme) {
        await LightningAlert.open({
            message: msg,
            theme: label, 
            label: theme
        });
        
    }
    showToast(msg,label,theme) {
        const event = new ShowToastEvent({
            title: label,
            message: msg,
            variant: theme,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        //alert(this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let a = JSON.parse(JSON.stringify(this.rows));
        // Return the value stored in the field
        let keyValue = (a) => {
            if(fieldname === 'Namerid' && a.ucinn_ascendv2__Primary_Contact__c!=null ){
                let con =a.ucinn_ascendv2__Primary_Contact__r;
                console.log(con);
                console.log(con.LastName);
            return con.LastName;
            }
            else if( fieldname === 'ucinn_ascendv2__Account__crid' && a.ucinn_ascendv2__Account__c!=null){
                let acc = a.ucinn_ascendv2__Account__r;
                if(acc.ucinn_ascendv2__Primary_Contact__c!=null){
                    let con = acc.ucinn_ascendv2__Primary_Contact__r;
                    return con.LastName;
                }
                return a[fieldname]; 
            }
            else
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        a.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.rows = a;
    }  

    handleSearch(event) {
        if(event!=null)
         this.searchKey = event.target.value.toLowerCase();
        

        if (this.searchKey) {
            this.rows = [...this.initialRecords];
 
            if (this.rows) {
                let searchRecords = [];
 
                for (let record of this.rows) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(this.searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
                this.rows = searchRecords;
            }
        } else {
            this.rows = [...this.initialRecords];
        }
    }
    // Navigate to the Assignments Tab
    navigateToAssignmentsRecentListView() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "ucinn_ascendv2__Assignment__c",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            },
        });
    }


    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // Update the uploadedFiles property to display file information
        this.uploadedFiles = uploadedFiles;
    }
}