import UIKit

class AnimatedImageFrame: NSObject {

    let image: UIImage
    let duration: Double
    
    init(image: UIImage, duration: Double) {
        self.image = image
        self.duration = duration
        super.init()
    }
    
}
