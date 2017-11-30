"use strict";
function sendRequestToiOS(request){
    var string = JSON.stringify(request);
    try {
        
        webkit.messageHandlers.callbackHandler.postMessage(string);
        
    } catch(err) {
        window.JSInterface.request(string)
        console.log("The native context does not exist yet");
    }
    return string;
}



function callGenerateCode(){
  var request = {action: "getClientCode",
    callback: "receivedTableCode"
  };
 
    sendRequestToiOS(request);
}



function startPolling(){
    var request = {
    action: "startPolling",
    callback: "startedPolling"
        
    };
    
    sendRequestToiOS(request);
}

function stopPolling(){
    var request = {action: "stopPolling",
    callback: "stoppedPolling"
    };
    
    sendRequestToiOS(request);
}

function getOrderDetails(){
    var request = {action: "getOrderDetails",
    callback: "receivedOrder",
    body:{
    isCachedOrder: false
    }
    };
    
    sendRequestToiOS(request);
    
}

function getOrderDetailsCache(){
    var request = {action: "getOrderDetails",
    callback: "receivedOrder",
    body:{
    isCachedOrder: true
    }
    };
    
    sendRequestToiOS(request);
    
}


function getPaymentMethods(){
    var request = {action: "getPaymentMethods",
    callback: "receivedPaymentMethods"
    };
    
    sendRequestToiOS(request);
    
}

function getFriendsList(){
    var request = {action: "getFriendsList",
    callback: "listOfFriends"
    };
    
    sendRequestToiOS(request);
}

function addFriend(){
    var request = {action: "addFriend",
    callback: "friendAdded",
    body:{
    code: "1234"
    }
    };
    
    sendRequestToiOS(request);
}

function sendFeedback(){
    var request = {action: "sendFeedback",
    callback: "feedbackSent",
    body:{
    orderId: "1234",
    stars: 1,
    comment: "hello"
    }
    };
    
    sendRequestToiOS(request);
}

function callWaiter(){
    var request = {action: "callWaiter",
    callback: "calledWaiter"
    };
    
    sendRequestToiOS(request);
}


function reorderItems(){
    var request = {action: "reorderItems",
    body:{
    items: [ {
            id:920836,
            name:"VEGETARIAN PIZZA",
            price:8.95,
            quantity:7,
            paid:false,
            serial_id:"994",
            valid_for_reorder:true,
            show_in_reorder:true,
            modifiers:[
            
            ]
            }]
        
    },
    callback: "itemsReordered"
    };
    
    sendRequestToiOS(request);
    
}


function makePaymentRequestByAmount(){
    var request = {
    action: "generatePaymentRequest",
    callback: "generatedPaymentRequest",
    body:{
    amount: "1.1",
    tip: 0.5,
    
    }
    };
    
    sendRequestToiOS(request);
}


function makePaymentRequestForFullBill(){
    var request = {
    action: "generatePaymentRequest",
    callback: "generatedPaymentRequest",
    body:{
    payFullAmount: true,
    tip: 0.5,
        
    }
    };
    
    sendRequestToiOS(request);
}

function makePaymentRequestByItem(){
    var request = {action: "generatePaymentRequest",
    callback: "generatedPaymentRequest",
    body:{
    items: [ {
            id:920836,
            name:"VEGETARIAN PIZZA",
            price:8.95,
            quantity:1,
            paid:false,
            serial_id:"994",
            valid_for_reorder:true,
            show_in_reorder:true,
            modifiers:[
            
            ]
            },
            {
            id:9202236,
            name:"Coke",
            price:1.05,
            quantity:2,
            paid:false,
            serial_id:"994",
            valid_for_reorder:true,
            show_in_reorder:true,
            modifiers:[
            
            ]
            }],
    tip: 0.5
    }
    };
    
    sendRequestToiOS(request);
}


function makePayment(){
    var request = {
    action: "makePayment",
    callback: "madePayment",
    body:{
    tip: "0.5",
    paymentMethod:{
    id: 10405,
    token: "I am a token",
    external_id: null,
    token_type: 1,
    source: "MCPCI",
    issuer_short: "VI",
    issuer_full: "visa",
    exp_month: "09",
    exp_year2: "17",
    exp_year4: 2017,
    last_4_digits: "1127",
    first_6_digits: "426428",
    first_4_digits: null,
    is_single_use: 0,
    is_short_live: 0,
    is_capped: 0,
    is_default: 1,
        name : "XXXX-1127"
    }
    }
    };
    
    sendRequestToiOS(request);
}



function completeDineInOrderCompleted(){
    var request = {action: "completeDineIn",
    callback: "callback",
    body:{reason: "completedOrder"  }
    };
    
    sendRequestToiOS(request);
    
}

function completeDineInCanceled(){
    var request = {action:
        "completeDineIn",
    callback: "completeFailed",
    body:{reason: "canceled"  }
    };
    sendRequestToiOS(request);
    
}



function getLocale(){
    var request = {action:
        "getLocale",
    callback: "gotLocale"
    };
    sendRequestToiOS(request);
    
}

function completeDineInOrderError(){
    var request = {action: "completeDineIn",
    callback: "completeFailed",
    body:{reason: "error",
    errorCode: 21,
        errorMessage: "failed"  }
    };
    
    sendRequestToiOS(request);
    
}

function getBenefits(){
    var request = {action: "getBenefits",
    callback: "gotBenefits",
    body:{
    restaurantId: "1234"
    }
    };
    
    sendRequestToiOS(request);
}

function redeemBenefit(){
    var request = {action: "redeemBenefit",
    callback: "redeemBenefit",
    body:{
    restaurantId: "1234",
    benefit:  {
        "id": "1",
        "provider": "2",
        "name": "3",
        "subtitle": "4",
        "description": "5",
        "redeemable": true,
        "image": null,
        "category_id": null,
        "redeem_method": "AUTO",
        "timing": {
            "start_time": "2017-04-01 08:15:30",
            "expire_time": "2017-04-01 08:15:30"
        }
    }
    }
    };
    
    sendRequestToiOS(request);
}
//
//
//function closeTab(){
//    var request = {action: "closeTab",
//    body:{
//    someKey: "someValue"
//    },
//    callback: "tabClosed"
//    };
//
//    sendRequestToiOS(request);
//
//}

//private methods

