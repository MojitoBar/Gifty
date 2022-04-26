//
//  ImageManager.swift
//  QRCode-Example
//
//  Created by judongseok on 2021/09/25.
//  Copyright © 2021 Hans Knoechel. All rights reserved.
//
import UIKit
import Photos

class ImageManager {
    static let shared = ImageManager()
    
    private let imageManager = PHImageManager()
    
    func requestImage(from asset: PHAsset, thumnailSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        self.imageManager.requestImage(for: asset, targetSize: thumnailSize, contentMode: .aspectFill, options: nil) { image, info in
            completion(image)
        }
    }
}
