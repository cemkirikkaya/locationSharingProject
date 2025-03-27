//
//  AudioMessage.swift
//  sos
//
//  Created by Cem Kırıkkaya on 25.12.2024.
//

import Foundation
import CoreData

@objc(AudioMessage)
public class AudioMessage: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioMessage> {
        return NSFetchRequest<AudioMessage>(entityName: "AudioMessage")
    }

        @NSManaged public var id: UUID?
        @NSManaged public var audioData: Data?
}
