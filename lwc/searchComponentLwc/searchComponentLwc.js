import { LightningElement, track } from 'lwc';

export default class SearchComponentLwc extends LightningElement {
    @track searchval;
    @track locationSearchVal;
    handleChange( event ){
        const value = event.target.value;
        this.searchval = value;
        const searchEvent = new CustomEvent(
            'search',
            {
                detail : this.searchval
            }
        );
        this.dispatchEvent(searchEvent);
    }

    handleLocationChange(event) {
        const value = event.target.value;
        this.locationSearchVal = value;
        const searchEvent = new CustomEvent(
            'locationsearch',
            {
                detail : this.locationSearchVal
            }
        );
        this.dispatchEvent(searchEvent);
    }
}