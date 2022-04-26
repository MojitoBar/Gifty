//
//  ViewController+CollectionView.swift
//  QRCode-Example
//
//  Created by judongseok on 2022/04/26.
//  Copyright © 2022 Hans Knoechel. All rights reserved.
//

import UIKit
// MARK: - Extension UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3 - 10 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
        let size = CGSize(width: width, height: width)
        return size
    }
}

// MARK: - Extension UICollectionViewDelegate & UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        DispatchQueue.main.async { [self] in
            loadImageLabel.text = "불러온 이미지는 \(barcodeDatas.count) 개 입니다."
        }
        
        return barcodeDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CSCollectionViewCell
        
        cell.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        cell.image.image = barcodeDatas[indexPath.row]
        cell.image.contentMode = .scaleAspectFill
        cell.image.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width / 3 - 10, height: collectionView.frame.width / 3 - 10)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        vcName?.modalTransitionStyle = .coverVertical
        vcName?.modalPresentationStyle = .fullScreen
        vcName?.paramImage = barcodeDatas[indexPath.row]
        vcName?.paramAsset = results[indexPath.row]
        vcName?.paramFetchResult = fetchPhotos
        index = indexPath.row
        self.present(vcName!, animated: true, completion: nil)
    }
}
