
function  getMasterpassToken(){
    
    var request = {action: "getMasterpassToken",
        callback: "callback" };
   
    sendRequestToiOS(request);
}


function  addMasterpassSuccess(){
   
    var request = {action: "addMasterpass",
    complitionStatus:"success",
        callback: "callback" ,
        payload: "payload"};
    
    sendRequestToiOS(request);
}



function  addMasterpassFail(){
   
    var request = {action: "addMasterpass",
    complitionStatus:"failed",
        callback: "callback",
        errorCode: 1,
        errorMessage:"error"};
    
    sendRequestToiOS(request);
}


function  addMasterpassCancelled(){
   
    var request = {action: "addMasterpass",
    complitionStatus:"cancelled",
    callback: "callback",
   };
    
    sendRequestToiOS(request);
}


function sendRequestToiOS(request){
    
    var string = JSON.stringify(request)
    
    try {

        webkit.messageHandlers.callbackHandler.postMessage(string);

    } catch(err) {
    	window.JSInterface.request(string)
        console.log('The native context does not exist yet');
    }
}
