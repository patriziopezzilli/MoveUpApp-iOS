//
//  NavigationHelper.swift
//  MoveUp
//
//  Created by iOS Developer on 30/12/24.
//

import Foundation
import Combine

extension Notification.Name {
    static let switchToBookingsTab = Notification.Name("switchToBookingsTab")
}

class NavigationHelper {
    static let shared = NavigationHelper()
    
    private init() {}
    
    func switchToBookingsTab() {
        NotificationCenter.default.post(name: .switchToBookingsTab, object: nil)
    }
}