({
    doInit: function (component, event, helper) {
        var action = component.get('c.getFollowers');
        action.setCallback(this, function(response){
            let state = response.getState();
            if ( state === 'SUCCESS' || state === 'DRAFT') {
            	let responseValue = response.getReturnValue();
            	let markers = [];
            	for ( let i =0 ; i < responseValue.length; i++ ){
            		let addr = responseValue[i].Location__c.split(',');
            		let city = '';
            		let country = '';
            		if (addr.length === 2) {
                        
            			city = addr[0].trim();
            			country = addr[1].trim();
                        console.log(' City ', city +' country ', country);
                        if ( country.length ==2 )
                            continue;
                        markers.push({
                            location: {
                                City: city,
                                Country: country
                            },
                            icon: 'custom:custom21',
                            title: responseValue[i].Name
                        });
        			}
        		}
                component.set('v.mapMarkers', markers);
                component.set('v.markersTitle', 'Twitter Followers');
				component.set('v.zoomLevel', 4);
                component.set('v.center', {
                    location: {
                        Latitude: '40.7831856',
                        Longitude: '-73.9675653',
                    },
                });
            } else if ( state === 'INCOMPLETE') {
            	
        	} else if ( state === 'Error') {
				let errors = response.getError();
				console.log(errors);                
            }
        });
        $A.enqueueAction(action);
    }
});