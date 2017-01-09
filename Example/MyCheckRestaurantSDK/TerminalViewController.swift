//
//  TerminalViewController.swift
//  MyCheckRestaurantSDK
//
//  Created by elad schiller on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MessageUI
class TerminalViewController: UIViewController {
    
    @IBOutlet weak var terminalView: UITextView!
    
    @IBOutlet weak var terminalHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        terminalView.isEditable = false;
        
        TerminalModel.shared.delegate = self
        terminalView.text = TerminalModel.shared.terminalString
        scrollToBottom()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: - actions
    
    @IBAction func dragged(_ objectToMove: UIPanGestureRecognizer) {

        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height
              let zero =  CGPoint(x: 0,y :0)
        
        let translation = objectToMove.translation(in: self.view)
        var point = CGPoint(x: objectToMove.view!.center.x , y: objectToMove.view!.center.y + translation.y)
        point.y = max(point.y , 20)
        point.y = min (point.y , screenHeight - 30)
        objectToMove.view!.center = point
        objectToMove.setTranslation(zero, in: self.view)
        var terminalFrame = terminalView.frame
        terminalFrame.size.height = screenHeight  - objectToMove.view!.frame.origin.y
        terminalFrame.origin.y = point.y
        
        terminalView.frame = terminalFrame
        
        if(objectToMove.state == .ended){
            UIView.animate(withDuration: 0.1, animations: {
                self.terminalHeight.constant = point.y - 30
                self.view.layoutIfNeeded()
            })
        }
    }
  
    
    @IBAction func sendEmailPressed(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("MyCheckRestaurantSDK iOS example app output")
        mailComposerVC.setMessageBody(terminalView.text, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        //        let alert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        //        present(alert, animated: true, completion: nil)
    }
    func scrollToBottom(){
        let bottom = NSMakeRange(terminalView.text.characters.count - 1, 1)
        terminalView.scrollRangeToVisible(bottom)
    }
    @IBAction func copyToClipboardPressed(_ sender: Any) {
        UIPasteboard.general.string = terminalView.text
    }
}


extension TerminalViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}

extension TerminalViewController: TerminalDelegate{
    func terminalOutputUpdated(output: String) {
        self.terminalView.text = output
        scrollToBottom()
        
    }
}

extension TerminalViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

    }
    
}

