import UIKit
import ImageIO
import MobileCoreServices

// Async NSOperation that handles image loading
class PhotoLoadOperation: NSOperation {
    
    let url: NSURL
    private(set) var image: UIImage?
    private(set) var animatedImage: AnimatedImage?
    
    override var completionBlock: (() -> Void)? {
        get {
            return super.completionBlock
        }
        set {
            if let block = newValue {
                super.completionBlock = {
                    dispatch_async(dispatch_get_main_queue()) {
                        block()
                    }
                }
            } else {
                super.completionBlock = newValue
            }
        }
    }
    
    init(url: NSURL) {
        self.url = url
        super.init()
    }
    
    override func main() {
        autoreleasepool {
            self.execute()
        }
    }
    
    private func execute() {
        // create request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        request.cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        
        var response: NSURLResponse? = nil
        var imageData: NSData? = nil
        
        // use cached response
        if let cachedResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request) {
            imageData = cachedResponse.data
        }
        // otherwise load
        else {
            var loadedResponse: NSURLResponse? = nil
            let loadedData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &loadedResponse, error: nil)
            
            response = loadedResponse
            imageData = loadedData
            
            if response != nil && imageData != nil {
                let cachedResponse = NSCachedURLResponse(response: response!, data: imageData!)
                NSURLCache.sharedURLCache().storeCachedResponse(cachedResponse, forRequest: request)
            }
        }
        
        // convert to image
        if imageData != nil {
            if let source = CGImageSourceCreateWithData(imageData, nil) {
                let type = CGImageSourceGetType(source) as NSString as String
                let count = CGImageSourceGetCount(source)
                
                // gif with more than 1 frame
                if type == (kUTTypeGIF as NSString as String) && count > 1 {
                    // make frames
                    var frames = Array<AnimatedImageFrame>()
                    
                    // loop through and create frames
                    for var i = 0; i < Int(count); ++i {
                        // get CGImage
                        let img = CGImageSourceCreateImageAtIndex(source, UInt(i), nil)
                        
                        // get properties
                        let props = CGImageSourceCopyPropertiesAtIndex(source, UInt(i), nil) as NSDictionary as Dictionary<String, AnyObject>
                        
                        // get gif properties
                        let gifprops = props[(kCGImagePropertyGIFDictionary as NSString as String)] as NSDictionary as Dictionary<String, AnyObject>
                        
                        // get gif duration
                        let gifduration = gifprops[(kCGImagePropertyGIFDelayTime as NSString as String)] as NSNumber
                        
                        // create frame
                        frames.append(AnimatedImageFrame(image: UIImage(CGImage: img)!, duration: gifduration.doubleValue))
                    }
                    
                    // create image
                    self.animatedImage = AnimatedImage(frames: frames)
                }
                // normal static image
                else {
                    self.image = UIImage(data: imageData!)
                }
            }
        }
    }
    
}
