//
//  NotificationNames.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import Foundation

extension Notification.Name {

    // Tool Pins
    static let eventPinDropped = Notification.Name("eventPinDropped")
    static let meetupPinDropped = Notification.Name("meetupPinDropped")
    static let helpPinDropped = Notification.Name("helpPinDropped")
    static let notePinDropped = Notification.Name("notePinDropped")

    // DROP MODE
    static let eventPinDropRejected = Notification.Name("eventPinDropRejected")
    static let enterDropMode = Notification.Name("enterDropMode")
    static let exitDropMode = Notification.Name("exitDropMode")
}

