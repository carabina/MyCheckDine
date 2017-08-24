# MyCheck Dine UI Web SDK

An SDK that enables the user to open a table at a restaurant, follow the order, reorder items and finally pay . The SDK supplies a View Controller that takes the user through the MyCheck Dine at table experience.


The basic flow of the transactions is:
-  The guest accesses the app to get a four digit code
- The code is given to the guest's food server who will access the open check on the POS and enter the code.
- The POS will connect the check with MyCheck services
- The guest will then be able to see the check and interact with the check by reordering existing items and paying.
- Once the guest pays the check he/she no longer has access to the check.


## Requirements

iOS 9 or above.

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
pod "MyCheckDineUIWeb"
```
Now you can run 'pod install'

## Use
In order to manage the users session (login, logout etc.) you will need to use the session singleton.

Start by adding
```
import MyCheckCore
```


to the top of the class where you want to use MyCheck.

In your app delegate's `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)` function call the configure function of the Session singleton:

```
Session.shared.configure(YOUR_PUBLISHABLE_KEY, environment: .sandbox)
```
This will setup the SDK to work with the desired environment.

Before using any other functions you will have to login the user. Login is done by first obtaining a refresh token from your server (that, in turn, will obtain it from the MyCheck server using the secret). Once you have the refresh token call the login function on the Session singleton:


```
Session.shared.login(REFRESH_TOKEN, success: HANDLE_SUCCESS
}, fail: HANDLE_FAIL)

```

#### Open a new table ####

Once you are logged in, you can open a table and create a DineInWebViewController object that will take the user through the Dine In process.
```
import MyCheckCore
import MyCheckDineUIWeb
```
A 4 digit pin will need to be generated and a ViewController instance created.  Use the *DineInWebViewControllerFactory* objet for this purpose. You will need to pass the business Id the user want to dine at.

```
DineInWebViewControllerFactory.dineIn(at: THE_BUSSINESS_ID , locale:THE_LOCALE, delegate: self)

```

Note that you will have to implement the *DineInWebViewControllerDelegate*. It will send you the ViewController when it is created, notify you of any errors, and update you when the user finished using the view controller (including the reason he finished and the last order state. Also, more parameters will need to be passed in order to support Apple Pay

#### Display an existing open table ####

If you would like to check wether or not a table is already open (e.g. when the app starts up) you will need to use the *Dine* singleton. 

Dine.shared.getOrder(success: { order in
//react to an open order
}, fail: {error in
//failed to get an open order
})

If an open order exists, create a *DineInWebViewController* using the factory method intended for open orders, and pass it the order you have just received from the getOrder callback.

```
DineInWebViewControllerFactory.dineInWithOpenOrder.dineIn(order: THE_ORDER, locale:THE_LOCALE, delegate: self)

```

#### Apple Pay ####

In order to support Apple Pay *DineInWebViewControllerFactory* s methods must be called with an *applePayController* and a *displayDelegate* .   

```
DineInWebViewControllerFactory.dineIn(at: THE_BUSSINESS_ID ,
locale:THE_LOCALE,
displayDelegate: self,
applePayController: Wallet.shared.applePayController
delegate: self)

```
They will enable the SDK to display Apple Pay UI in order to create tokens and charge the user.

## Authors

Elad Schiller, eladsc@mycheck.co.il
## License

Please read the LICENSE file available in the project
