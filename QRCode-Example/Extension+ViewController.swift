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
        
        // 10
        // 0 3, 3 6, 6 10
        let indexArr: [Int] = [0, fetchPhotos!.count / 3, fetchPhotos!.count / 3 * 2, fetchPhotos!.count]
        
        for i in 0..<3 {
            DispatchQueue.global().async { [self] in
                for j in indexArr[i]..<indexArr[i + 1] {
                    DispatchQueue.main.async { [self] in
                        // 3
                        setText()
                        collectionView.reloadData()
                        endLoading()
                    }
                    autoreleasepool {
                        var photo: PHAsset? = fetchPhotos!.object(at: j)
                        var image: UIImage? = getAssetThumbnail(asset: photo!)
                        if let image = image{
                            let data = UIImagePNGRepresentation(image)
                            if let data = data{
                                scanImage(data: data, photo: photo!)
                            }
                        }
                        image = nil
                        photo = nil
                    }
                    loading += 1
                }
            }
        }
    }
}
