//
//  Extension+ViewController.swift
//  QRCode-Example
//
//  Created by judongseok on 2022/04/20.
//  Copyright © 2022 Hans Knoechel. All rights reserved.
//

import AVKit
import UIKit
import Vision
import Photos

extension ViewController {
    
    // MARK: - 사진 앱에서 이미지 가져오기
    func setPhotoLibraryImage() {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchPhotos = PHAsset.fetchAssets(with: fetchOption)
        
        DispatchQueue.global().async { [self] in
            isLoading = true
            DispatchQueue.main.sync {
                loadingPer.isHidden = false
                fetchButton.isHidden = true
                loadingLabel.isHidden = true
                activityIndicator.startAnimating()
            }
        }
        
        // a ~ b
        // a ~ a + ((b-a) / 3)
        let indexArr: [Int] = [startIndex - 1,
                               startIndex - 1 + (endIndex - (startIndex - 1)) / 3,
                               startIndex - 1 + (endIndex - (startIndex - 1)) / 3 * 2,
                               endIndex]
        
        for i in 0..<3 {
            DispatchQueue.global().async { [self] in
                for j in indexArr[i]..<indexArr[i + 1] {
                    loading += 1
                    autoreleasepool {
                        let photo: PHAsset? = fetchPhotos!.object(at: j)
                        let image: UIImage? = getAssetThumbnail(asset: photo!)
                        if let image = image{
                            let data = UIImagePNGRepresentation(image)
                            if let data = data{
                                scanImage(data: data, photo: photo!)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async { [self] in
                        // 3
                        setText()
                        collectionView.reloadData()
                        endLoading(count: loading, photos: endIndex - startIndex)
                    }
                }
            }
        }
    }
}
