#
# Be sure to run `pod lib lint MyCheckDine.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyCheckDine'
  s.version          = '1.3.4'
s.summary          = 'A SDK that enables the developer to open a table at a restaurant, follow the order and reorder items.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      =  <<-DESC
# MyCheck Dine SDK

An SDK that enables the developer to open a table at a restaurant, follow the order and reorder items (payment - coming soon).

This SDK will enable your app to access an open check on a table at a restaurant, view the check (bill), reorder items and pay the check (payment functions coming soon).

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
pod "MyCheckDine"
```
Now you can run 'pod install'

## Use
The Dine Singleton will be the point of contact that will allow you to create, follow and make actions on the users order. In order to manage the users session (login, logout etc.) you will need to use the session singleton.

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
Once you are logged in, you can open a table. Now you can start doing  dine in specific actions using the Dine singleton. Import the Dine module of the SDK.
```
import MyCheckDine
```

Bellow is a flow chart that explains the Dine in flow and explains what functions need to be called in each stage of the user experience.
![Dine flow chart](https://s3-eu-west-1.amazonaws.com/docs.mycheckapp.com/Resources/flowChart.jpg "Dine flow chart")
The first step in the process is generating a 4 digit code. The code generated by the MyCheck server is valid for a limited time, for a specific user in a specific location. This code, when entered into the POS enables MyCheck to sync the client with his order on the POS and can start receiving order updates and perform actions on it. The user will need to have a method of payment in order for this to succeed. Once you have received a code, display it to the user so he, in turn, can show it to his waiter / bartender. If you wish to support Apple Pay you will need some additional setup, please read the Apple Pay section.

```
Dine.shared.generateCode(hotelId: HOTEL_ID , restaurantId: RESTUARANT_ID, success: HANDLE_SUCCESS
}, fail: HANDLE_FAIL)

```

Now that a code was generated and displayed you will probably want to start polling the MyCheck server in order to get order updates. You will get an update when the order is opened, and on every change made to the bill. In order to poll the order, turn on the poller and implement the 'OrderPollerDelegate'.

```
Dine.shared.poller.delegate = self

MyCheck.shared.poller.startPolling()

```

The delegate example implementation:

```
extension YOUR_VIEWCONTROLLER : OrderPollerDelegate{

func orderUpdated(order:Order){

//Deal with order updates. Check the 'status' variable to make sure the status didn't change, otherwise update the order displayed to the user with the updated bill.
}


func failingToReceiveUpdates(lastReceivedError: NSError , failCount:Int){
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
### Payment
If you have an open table with a non zero balance and a payment method you can make a payment.
The first step is to create a `PaymentDetails` object

```
let details = PaymentDetails(order: THE_ORDER, amount: THE_AMOUNT_TO_CHARGE, tip: TIP_AMOUNT, paymentMethod: A_PAYMENT_METHOD)

// OR

let details = PaymentDetails(order: THE_ORDER, items: ITEMS_THAT_SHOULD_BE_BOUGHT, tip: TIP_AMOUNT, paymentMethod: A_PAYMENT_METHOD)
```

The `PaymentDetails` has 2 failable constructors. One is for paying by amount and the second is for paying by items. The constructors will fail if the order supplied is not open or if the amount is greater than the order balance.
You will also need to get a `PaymentMethodInterface` object, For more on this please review the MyCheckWalletUI documents.
Once you have a `PaymentDetails` object call the `makePayment` function.

```
Dine.shared.makePayment(paymentDetails: details, displayDelegate: self, success: {

}, fail: {error in

})
```

## Apple Pay

In order to set up Apple Pay please review the MyCheckWallet or MyCheckWalletUI docs. Once Apple Pay is set up their are 2 additional changes you will need to make in order for it to work with the Dine SDK.
### Generate Code
When generating a code MyCheck must be able to charge the default payment method without the users interaction in certain cases (for example if the user walks out and forgets to pay). Apple Pay creates tokens that can be used only once that expires after some time. For this reason we will need to prompt the user to Pay with Apple Pay at this point.
In order to accomplish this the generateCode function has 2 extra optional parameters (that are required for Apple Pay support):
1. DisplayViewControllerDelegate :  The delegate function will be called when a Apple Pay view controller needs to be displayed or dismissed.
2. ApplePayController -  The controller will supply the Dine SDK with the means to query the wallet about Apple Pay and create Apple Pay tokens. You should get the instance of the ApplePayController from the Wallet singleton (e.g. 'Wallet.shared.applePayController')

The code snippet bellow demonstrates how the generate code is called when Apple Pay must be supported

```
Dine.shared.generateCode(hotelId: nil, restaurantId: THE_ID, displayDelegate: self, applePayController: Wallet.shared.applePayController, success: {
code in

}
}, fail: {error in

})


//DisplayViewControllerDelegate implementation
func display(viewController: UIViewController) {

self.present(viewController, animated: true, completion: nil)

}


func dismiss(viewController: UIViewController) {

viewController.dismiss(animated: true, completion: nil)

}
```
In the same manner, you must pass the `displayDelegate` to the payment function in order for Apple Pay to work.


##Benefits

In order to support benefits add the following line to your podfile:
```
pod "MyCheckDine/Benefits"
```

You can now use the static functions in the Benefits class to query and redeem benefits. Please refer to the API docs for more information.
## Authors

Elad Schiller, eladsc@mycheck.co.il
## License

Please read the LICENSE file available in the project


DESC


  s.homepage         = 'http://www.mycheck.io/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'elad schiller' => 'eladsc@mycheck.co.il' }
s.source           = { :git => 'https://bitbucket.org/erez_spatz/mycheckrestaurantsdk-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.source_files = 'MyCheckDine/Classes/*' , 'MyCheckDine/Classes/extenshions tools/**' ,'MyCheckDine/Classes/Networking/**','MyCheckDine/Classes/objects/**','MyCheckDine/Classes/OrderPoller/**'
s.dependency 'MyCheckCore'
s.dependency   'Gloss', '~> 1.1'

  # s.resource_bundles = {
  #   'MyCheckDine' => ['MyCheckDineyes/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'


s.subspec 'Benefits' do |benefits|
benefits.dependency 'MyCheckCore'

benefits.source_files = 'MyCheckDine/Classes/Benefits/**/*'
benefits.ios.deployment_target = '9.0'
benefits.platform = :ios, '9.0'

end


end
