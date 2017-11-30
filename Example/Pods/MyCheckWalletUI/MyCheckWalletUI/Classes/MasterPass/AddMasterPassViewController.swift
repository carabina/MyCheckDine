//
//  AddMasterPassViewController.swift
//  Pods
//
//  Created by elad schiller on 8/7/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import WebKit
import MyCheckCore


/// The various reasons the view controller was dismissed
///
/// - userLeft: The user pressed the x button and decided to leave the dine in flow.
/// - error: An error accaured and forced MyCheck to stop the flow.
/// - completedOrder: The order was paid in full or closed / canceled from the POS.
internal enum AddMasterPassViewControllerCompletitionReason{
    
    case cancelled
    
    case failed(NSError)
    
    case success(String)
    
    init?(reason:String, payload:String? = nil,  errorCode:Int? = nil, errorMessage:String? = nil){
        
        switch reason{
        case "failed":
            let errorCode =  errorCode ?? ErrorCodes.masterPassFailed.getError().code
                let errorMessage = errorMessage ?? ErrorCodes.masterPassFailed.getError().localizedDescription
            
            let error = NSError(domain: Session.Const.serverErrorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey : errorMessage])
            
            self = .failed(error)
            
        case "success":
            guard let payload = payload else{
            return nil
            }
            self = .success(payload)
            
        case "cancelled":
            self = .cancelled
            
        default: return nil
        }
        
        
    }
}


/// Returns updates about the DineInWebViewController that might require actions made by the user of the SDK
internal protocol AddMasterPassViewControllerDelegate{
    
    
    
    /// This function will be called when the view controller needs to be dismissed. It  passes information with the status and reason for completion.
    ///
    ///   - controller: The view controller that must be dismissed.
    ///   - reason: The reason for dismissing the view controller.
    func addMasterPassViewControllerComplete(controller: UIViewController , reason:AddMasterPassViewControllerCompletitionReason)
    
}





protocol AddMasterPassDisplayLogic: class
{
  func runJSOnWebview(viewModel: AddMasterPass.ViewModel)
    
    func complete(viewModel: AddMasterPass.AddMasterpass.ViewModel)

}


internal class AddMasterPassViewController: UIViewController
{
    
    
    internal var interactor: AddMasterPassBusinessLogic?
    
    
    //web view related objects
    internal var webView: WKWebView?
    
    internal var nativeCallHandler: AddMasterPassCallHandler?
    
    internal var delegate: AddMasterPassViewControllerDelegate?
    
    internal var urlStr: String?
    
    private var webConfig: WKWebViewConfiguration {
        get {
            let webCfg = WKWebViewConfiguration()
            let userController = WKUserContentController()
             nativeCallHandler = AddMasterPassCallHandler(interactor: interactor!)
            userController.add(nativeCallHandler!, name: "callbackHandler")
            webCfg.userContentController = userController;
            return webCfg;
        }
    }
    
 
    
    // MARK: Object lifecycle
    
    internal init(url: String, payload: MasterPassInitPayload, delegate:AddMasterPassViewControllerDelegate)
    {
        super.init(nibName: nil, bundle: nil)
        setup()
        self.interactor?.setup(request: AddMasterPass.Setup.Request(payload: payload))
        self.delegate = delegate
        self.urlStr = url
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = AddMasterPassInteractor()
        let presenter = AddMasterPassPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController

    }
    
    // MARK: Routing
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
     
    }
    
    // MARK: View lifecycle
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        initWebView()
        self.view.backgroundColor = UIColor.cyan
    }
    
    private func initWebView(){
        // The URL to load
//        let bundle =  AddMasterPassViewController.getBundle( Bundle(for: AddMasterPassViewController.classForCoder()))
//        
//        let url = bundle.url(forResource: "test", withExtension: "html")
//        // Initialize our NSURLRequest
//        let request = URLRequest(url: url!)
        
        let request = URLRequest(url: URL(string: urlStr!)!)
        webView = WKWebView(frame: self.view.bounds, configuration: webConfig)
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView!)
        webView!.load(request)
        
    }
    
    internal static func getBundle(_ bundle: Bundle) -> Bundle{
        
        let bundleURL = bundle.url(forResource: "MyCheckWalletUI", withExtension: "bundle")
        let finalBundle = Bundle(url: bundleURL!)
        return finalBundle!
    }
    
}

extension AddMasterPassViewController: AddMasterPassDisplayLogic{
    func complete(viewModel: AddMasterPass.AddMasterpass.ViewModel) {
        self.delegate?.addMasterPassViewControllerComplete(controller: self, reason: viewModel.complitionStatus)
    }

  func runJSOnWebview(viewModel: AddMasterPass.ViewModel) {
    self.webView?.evaluateJavaScript(viewModel.JSToBeInjected, completionHandler: nil)
  }

   }
