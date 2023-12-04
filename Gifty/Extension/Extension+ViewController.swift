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
        guard let fetchPhotos = fetchAssetsFromLibrary() else { return }

        setLoadingState(true)
        processImagesWithOperationQueue(fetchPhotos: fetchPhotos)
    }

    private func fetchAssetsFromLibrary() -> PHFetchResult<PHAsset>? {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: fetchOption)
    }

    private func setLoadingState(_ isLoading: Bool) {
        DispatchQueue.main.async { [self] in
            loadingPer.isHidden = !isLoading
            fetchButton.isHidden = isLoading
            loadingLabel.isHidden = isLoading
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }

    private func processImagesWithOperationQueue(fetchPhotos: PHFetchResult<PHAsset>) {
        let processingQueue = OperationQueue()
        processingQueue.maxConcurrentOperationCount = 5 // 동시에 실행할 작업 수

        for index in 0..<fetchPhotos.count {
            processingQueue.addOperation {
                self.processImageAtIndex(index, from: fetchPhotos)
            }
        }
    }

    private func processImageAtIndex(_ index: Int, from fetchPhotos: PHFetchResult<PHAsset>) {
        autoreleasepool {
            if let photo = fetchPhotos.object(at: index) as PHAsset?,
               let data = getAssetThumbnail(asset: photo).pngData() {
                scanImage(data: data, photo: photo)
            }
        }
        
        DispatchQueue.main.async {
            self.updateUIAfterImageProcessing()
        }
    }

    private func updateUIAfterImageProcessing() {
        loading += 1
        setText()
        collectionView.reloadData()
        endLoading(count: loading, photos: fetchPhotos?.count ?? 0)
    }
}
