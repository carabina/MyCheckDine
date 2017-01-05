//
//  TerminalViewController.swift
//  MyCheckRestaurantSDK
//
//  Created by elad schiller on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {

    @IBOutlet weak var terminalView: UITextView!
  
    @IBOutlet weak var terminalHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

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
    @IBAction func swipedUp(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
        self.terminalHeight.constant += 210
            let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.height

            if ( self.terminalHeight.constant > screenHeight - 60){
                self.terminalHeight.constant = screenHeight
            }
            
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func swipedDown(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            
        self.terminalHeight.constant  -= 210
            if ( self.terminalHeight.constant < 80){
                self.terminalHeight.constant = 0
            }
            self.view.layoutIfNeeded()

        })
    }
    
    func scrollToBottom(){
        let bottom = NSMakeRange(terminalView.text.characters.count - 1, 1)
        terminalView.scrollRangeToVisible(bottom)
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
