/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit
import Photos

import Combine

class PhotoWriter {
  enum Error: Swift.Error {
    case couldNotSavePhoto
    case generic(Swift.Error)
  }
    
    static func save(_ image: UIImage) -> Future<String, PhotoWriter.Error> {
      return Future { resolve in
        do {
            // 1 First, you create a request to store image.
            try PHPhotoLibrary.shared().performChangesAndWait {
                // 2 Then, you attempt to get the newly-created asset's identifier via request.placeholderForCreatedAsset?.localIdentifier.

                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                // 3 If the creation has failed and you didn't get an asset id back, you resolve the future with a PhotoWriter.Error.couldNotSavePhoto error.

                guard let savedAssetID = request.placeholderForCreatedAsset?.localIdentifier else {
                    return resolve(.failure(.couldNotSavePhoto)) }
                // 4 Finally, in case you got back a savedAssetID, you resolve the future with success.
                resolve(.success(savedAssetID))

            }
            
        } catch {
        resolve(.failure(.generic(error))) }
      }
    }
  
}
