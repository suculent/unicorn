//
//  YMSearchPhotosIntentHandler.swift
//  UnicornChat
//
//  Created by Matěj Sychra on 17/06/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

/*
 Abstract:
 The handler class for YMSearchPhotosIntent.
 */

import Foundation
import Intents
import UnicornCore

class YMSearchPhotosIntentHandler: NSObject, INSearchForPhotosIntentHandling {
    
    // MARK: 1. Resolve
    func resolveRecipients(forSendMessage intent: INSearchForPhotosIntent, with completion: ([INPersonResolutionResult]) -> Swift.Void) {
        
        if let recipients = intent.recipients {
            var resolutionResults = [INPersonResolutionResult]()
            
            for recipient in recipients {
                let matchingContacts = UCAddressBookManager().contacts(matchingName: recipient.displayName)
                
                switch matchingContacts.count {
                case 2 ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    let disambiguationOptions: [INPerson] = matchingContacts.map { contact in
                        return contact.inPerson()
                    }
                    
                    resolutionResults += [INPersonResolutionResult.disambiguation(with: disambiguationOptions)]
                    
                case 1:
                    let recipientMatched = matchingContacts[0].inPerson()
                    resolutionResults += [INPersonResolutionResult.success(with: recipientMatched)]
                    
                case 0:
                    resolutionResults += [INPersonResolutionResult.unsupported(with: INIntentResolutionResultUnsupportedReason.none)]
                    
                default:
                    break
                }
            }
            
            completion(resolutionResults)
            
        } else {
            // No recipients are provided. We need to prompt for a value.
            completion([INPersonResolutionResult.needsValue()])
        }
    }
    
    func resolveContent(forSendMessage intent: INSearchForPhotosIntent, with completion: (INStringResolutionResult) -> Swift.Void) {
        if let text = intent.content where !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        }
        else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // MARK: 2. Confirm
    func confirm(sendMessage intent: INSearchForPhotosIntent, completion: (INSearchForPhotosIntentResponse) -> Swift.Void) {
        
        if UCAccount.shared().hasValidAuthentication {
            completion(INSendMessageIntentResponse.init(code: INSendMessageIntentResponseCode.success, userActivity: nil))
        }
        else {
            // Creating our own user activity to include error information.
            let userActivity = NSUserActivity.init(activityType: String(INSendMessageIntent))
            userActivity.userInfo = [NSString(string: "error"):NSString(string: "UserLoggedOut")]
            
            completion(INSendMessageIntentResponse.init(code: INSendMessageIntentResponseCode.failureRequiringAppLaunch, userActivity: userActivity))
        }
    }
    
    // MARK: 3. Handle
    func handle(sendMessage intent: INSearchForPhotosIntent, completion: (INSearchForPhotosIntentResponse) -> Swift.Void) {
        if intent.recipients != nil && intent.content != nil {
            // Send the message.
            let success = UCAccount.shared().sendMessage(intent.content, toRecipients: intent.recipients)
            completion(INSendMessageIntentResponse.init(code: success ? .success : .failure, userActivity: nil))
        }
        else {
            completion(INSendMessageIntentResponse.init(code: INSendMessageIntentResponseCode.failure, userActivity: nil))
        }
    }
}
