import UIKit

class AnimatedImage: NSObject {

    let frames: Array<AnimatedImageFrame>
    
    init(frames: Array<AnimatedImageFrame>) {
        self.frames = frames
        super.init()
    }
    
}
