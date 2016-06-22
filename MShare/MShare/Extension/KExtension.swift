//
//  GTLDriveFileExtension.swift
//  MShare
//
//  Created by Lam Le on 6/22/16.
//  Copyright © 2016 Legiti Ltd. All rights reserved.
//

import Foundation
import GoogleAPIClient
let VIDEOS_TYPES:[String] = ["video/x-msvideo","video/msvideo","video/avi","video/x-matroska","video/mp4"];
let AUDIOS_TYPES:[String] = ["audio/mpeg","audio/wav","audio/x-wav","audio/aiff","audio/x-aiff","audio/x-mpequrl"]
public extension GTLDriveFile{
    public func isVideoFile()->Bool{
        
        return VIDEOS_TYPES.contains(mimeType);
    }
    
    public func isAudioFile()->Bool{
        
        return AUDIOS_TYPES.contains(mimeType);
    }
    
    public func isDirectory()->Bool{
        
        return mimeType == "application/vnd.google-apps.folder";
    }
}