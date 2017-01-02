# MyCheck Restaurant SDK

An SDK that enables the developer to open a table at a restaurant, follow the order and reorder items.


## Requirements

iOS 8 or above.

Swift 3.0

## Installation

MyCheck Restaurant SDK is available through [CocoaPods](http://cocoapods.org). You will first need to ask a MyCheck team member to give you read privileges to the MyCheck Repository. Once you have gotten the privileges, install it by simply adding the following lines to the top of your Podfile:

```
source 'https://bitbucket.org/erez_spatz/pod-spec-repo.git'
source 'https://github.com/CocoaPods/Specs.git'
```
This will set both the public CocoaPods repo and the MyCheck private repo as targets for CocoaPods to search for frameworks from.

You can add YOUR_USER_NAME@ before the 'bitbucket.org' so the pod tool won't need to ask you for it every time you update or install.

Inside the target add:

```
pod "MyCheckRestaurantSDK"
```
Now you can run 'pod install'

## Use
The MyCheck Singleton will be the single point of contact that will allow you to create, follow and make actions on the users order.

Start by adding
```
import MyCheckRestaurantSDK
```


to the top of the class where you want to use MyCheck.

In your app delegate's `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)` function call the configure function of the MyCheckRestaurantSDK singleton:

```
MyCheck.shared.configure(YOUR_PUBLISHABLE_KEY, environment: .sandbox)
```
This will setup the SDK to work with the desired environment.

Before using any other functions you will have to login the user. Login is done by first obtaining a refresh token from your server (that, in turn, will obtain it from the MyCheck server using the secret). One you have the refresh token call the login function on the MyCheck singleton:


```
MyCheck.shared.login(REFRESH_TOKEN, success: HANDLE_SUCCESS
}, fail: HANDLE_FAIL)

```
Once you are logged in, you can open a table. The first step in the process is generating a 4 digit code. The code generated by the MyCheck server is valid for a limited time, for a specific user in a specific location. This code, when entered into the POS enables MyCheck to sync the client with his order on the POS and can start receiving order updates and perform actions on it. The user will need to have a method of payment in order for this to succeed. Once you have received a code, display it to the user so he, in turn, can show it to his waiter / bartender.

```
MyCheck.shared.generateCode(hotelId: HOTEL_ID , restaurantId: RESTUARANT_ID, success: HANDLE_SUCCESS
}, fail: HANDLE_FAIL)

```

Now that a code was generated and displayed you will probably want to start polling the MyCheck server in order to get order updates. You will get an update when the order is opened, and on every change made to the bill. In order to poll the order, turn on the poller and implement the 'OrderPollerDelegate'.

```
MyCheck.shared.poller.delegate = self

MyCheck.shared.poller.startPolling()

```

The delegate example implementation:

```
extension YOUR_VIEWCONTROLLER : OrderPollerDelegate{

func orderUpdated(order:Order){

//Deal with order updates. Check the 'status' variable to make sure the status didn't change, otherwise update the order displayed to the user with the updated bill.
}


func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int){
//this callback will be called if the poller failed the last few calls to the MyCheck server. This means your app may not be in sync with the POS.
}
}
```


In order to reorder items send an array of tuples to the reorder call. Each tuple has an Int representing the amount to order and the item to reorder. 

```
MyCheck.shared.reorderItems(items: [(3, order.items.first!)], success: {
//Handle success
}, fail: {error in
// handle fail
})
```
## Authors

Elad Schiller, eladsc@mycheckapp.com
## License

Please read the LICENSE file available in the project
