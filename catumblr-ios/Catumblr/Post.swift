import Foundation

// Model class representing a single tumblr post
class Post {
    
    // Model class representing a single photo in a tumblr post
    class Photo {
        
        let url: NSURL
        let width: UInt
        let height: UInt
        
        class func fromJSONRepresentation(JSONRepresentation: AnyObject?) -> Photo? {
            if let JSONDictionary = JSONRepresentation as? Dictionary<String, AnyObject> {
                let JSONURL = JSONDictionary["url"] as? NSString as? String
                let JSONWidth = JSONDictionary["width"] as? NSNumber
                let JSONHeight = JSONDictionary["height"] as? NSNumber
                
                if JSONURL != nil && JSONWidth != nil && JSONHeight != nil {
                    return self(url: NSURL(string: JSONURL!)!,
                                width: JSONWidth!.unsignedLongValue,
                                height: JSONHeight!.unsignedLongValue)
                }
            }
            return nil
        }
        
        required init(url: NSURL, width: UInt, height: UInt) {
            self.url = url
            self.width = width
            self.height = height
        }
        
    }
    
    let timestamp: UInt
    let photos: Array<Photo>
    let tags: Array<String>
    
    class func fromJSONRepresentation(JSONRepresentation: AnyObject?) -> Post? {
        if let JSONDictionary = JSONRepresentation as? Dictionary<String, AnyObject> {
            let JSONTimestamp = JSONDictionary["timestamp"] as? NSNumber
            let JSONPhotos = JSONDictionary["photos"] as? NSArray as? Array<Dictionary<String, AnyObject>>
            let JSONType = JSONDictionary["type"] as? NSString as? String
            let JSONTags = JSONDictionary["tags"] as? NSArray as? Array<String>
            
            // ignore posts which don’t have exactly 1 photo
            if JSONPhotos?.count != 1 {
                return nil
            }
            let JSONPhotosSizes = JSONPhotos?[0]["alt_sizes"] as? NSArray as? Array<Dictionary<String, AnyObject>>
            
            if JSONTimestamp != nil && JSONPhotosSizes != nil && JSONType == "photo" && JSONTags != nil {
                
                var photos = Array<Photo>()
                for JSONPhoto in JSONPhotosSizes! {
                    
                    if let photo = Photo.fromJSONRepresentation(JSONPhoto) {
                        photos.append(photo)
                    }
                }
                
                return self(timestamp: JSONTimestamp!.unsignedLongValue, photos: photos, tags: JSONTags!)
            }
        }
        return nil
    }
    
    required init(timestamp: UInt, photos: Array<Photo>, tags: Array<String>) {
        self.timestamp = timestamp
        self.photos = photos
        self.tags = tags
    }
    
    func bestFittingPhotoForPixelWidth(pixelWidth: Float) -> Photo? {
        var best: Photo? = nil
        var bestDelta: Float = 0
        for photo in self.photos {
            if bestDelta == 0 {
                best = photo
            } else if (abs(pixelWidth - Float(photo.width)) < bestDelta) {
                best = photo
            }
            bestDelta = abs(pixelWidth - Float(photo.width))
        }
        return best
    }
    
}