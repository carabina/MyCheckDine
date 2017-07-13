//
//  DisplayViewControllerDelegate.swift
//  Pods
//
//  Created by elad schiller on 6/28/17.
//
//

import Foundation

public protocol DisplayViewControllerDelegate {
    func display(viewController: UIViewController);
    func dismiss(viewController: UIViewController);

}
