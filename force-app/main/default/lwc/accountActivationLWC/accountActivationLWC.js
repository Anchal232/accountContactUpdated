import { LightningElement, track, api } from 'lwc';
import userHasAccountManagerPS from '@salesforce/customPermission/Account_Manager_CP';
import activateAccount from '@salesforce/apex/ActivateAccountClass.activateAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountActivationLWC extends LightningElement {
    @api recordId;
    @track isAccountManager = false;

    connectedCallback(){
        this.isAccountManager = userHasAccountManagerPS;
    }

    handleClick(){
        console.log('recordId: ', this.recordId);
        activateAccount({recordId: this.recordId})
        .then((result)=>{
            console.log('result: ', result);
            this.toastEvent('Success!', 'Successfully Activated Account', 'Success');
        })
        .catch((error)=>{
            if(error.body.message === 'Script-thrown exception');
            this.toastEvent('Error!', 'Either account type is not customer or summary is empty', 'Error')
        })

    }

    toastEvent(title, message, variant){
        this.dispatchEvent(new ShowToastEvent({title: title,message: message, variant: variant}));
    }
}