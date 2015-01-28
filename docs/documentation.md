# Catumblr

Catumblr is a small but simple iOS application built for those looking to learn by example. The application is a single endless scrolling collection view of cat photos from Tumblr’s public API.

## Features

* 100% natively coded in Swift
* Cocoa Auto Layout
* Code based views
* JSON REST API fetching, and deserializing
* Image loading & caching
* Endless scrolling
* Animated GIF loading and playback

## Files

* **assets** - contains the editable .psd files used to generate the icon and default screens
* **docs** - contains .md and .pdf formatted documentation
* **catumblr-ios** - contains the Xcode project and source files

## Requirements

* iOS 7.0/8.0 Deployment
* Xcode 6
* Your own Tumblr API key.

## Setup

### Getting a Tumblr API Key

1. Visit [Tumblr](https://www.tumblr.com/oauth/apps) to obtain an OAuth API key.
2. Open Configuration.swift and edit the OAuth API key.

## Xcode / Project Source Files

###### Bridging-Header.h

Standard swift bridging header to expose Objective-C code to swift. Catumblr does not use any Objective-C code so this file is empty but configured if further modifications require it.

###### Configuration.swift

Contains a few configuration variables used by the application such as the Tumblr API key, the tag used to fetch posts and the title of the view controller.

###### AppDelegate.swift

Standard iOS application delegate with basic setup.

###### Models/Post.swift

Model class for each Tumblr post loaded from Tumblr’s public REST API. The model code also contains the JSON deserialization.

###### Models/AnimatedImage.swift

Model class for each animated gif image.

###### Models/AnimatedImageFrame.swift

Model class for each frame inside an animated gif image.

###### Controllers/NavigationController.swift

A basic NavigationController pre-configured with a black navigation bar, light status bar and custom font.

###### Controllers/StreamViewController.swift

The main view controller that manages fetching data from Tumblr’s API, updating a UICollectionView and endless scroll.

###### Views & Cells/PhotoCollectionViewCell.swift

The UICollectionViewCell subclass used to display the posts

###### Operations/PhotoLoadOperation.swift

A NSOperation subclass that manages loading images from Tumblr. It caches images into the global shared NSURLCache and ensures images are never loaded from the network if they exist in the cache.

###### Images.xcassets

Standard Xcode assets bundle

###### Supporting Files/Info.plist

Standard Xcode application info plist

###### Libraries/Snappy.swift

Auto Layout library to makes auto layout much easier to work with. You can see documentation about snappy [here](https://github.com/Masonry/Snappy/tree/develop).

## Support

If you need help, or have questions via email please send them to [support@zwopple.com](mailto:support@zwopple.com).