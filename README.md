## Features
Enpand QLPreviewController to support remote file preview. Use Alamofire as a dependency to load file. 

## Installation

### Carthage
To integrate FilePreviewController into your Xcode project using Carthage, specify it in your `Cartfile`:

``` bash
$ github "teambition/FilePreviewController"
```

Then, run the following command to build the FilePreviewController framework:

``` bash
$ carthage update
```

If Alamofire is not used in your project, you have to **drag it your self into your project** from the [Carthage/Build] folder.

## Run Demo

``` bash
$ git clone https://github.com/teambition/FilePreviewController.git
```
And then

``` bash
$ carthage update
```

## Usage
Implement the QLPreviewControllerDataSource protocol to provide data source:

``` swift
import FilePreviewController

func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int

func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem
```

Implement the FilePreviewControllerDelegate protocol to provide downloading error handling:

``` swift
previewController.controllerDelegate = self

func previewController(controller: FilePreviewController, failedToLoadRemotePreviewItem item: QLPreviewItem, error: NSError)

```

Then push the view controller into navigation controller.

## License
FilePreviewController is released under the MIT license. See LICENSE for details.

