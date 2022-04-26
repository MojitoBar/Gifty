//
//  ViewController.swift
//  QRCode-Example
//
//  Created by Hans Knöchel on 09.06.17.
//  Copyright © 2017 Hans Knoechel. All rights reserved.
//
import UIKit
import Vision
import Photos
import CoreData

class ViewController: UIViewController {
    // MARK: - IBOutlet Variable
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingPer: UILabel!
    @IBOutlet weak var fetchButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadImageLabel: UILabel!
    @IBOutlet weak var reloadBtn: UIButton!
    @IBOutlet weak var optionBtn: UIButton!
    
    // MARK: -IBAction Function
    @IBAction func reloadBtn(_ sender: Any) {
        if !isLoading {
            isLoading = true
            // loading 초기화
            loading = 0
            // 애니메이션 시작
            activityIndicator.startAnimating()
            // UI변화
            loadingPer.isHidden = false
            fetchButton.isHidden = true
            loadingLabel.isHidden = true
            
            barcodeDatas = []
            
            // UI변화는 main thread 에서
            DispatchQueue.main.async { [self] in
                collectionView.reloadData()
            }
            setPhotoLibraryImage()
            
            // UI변화는 main thread 에서
            DispatchQueue.main.async { [self] in
                collectionView.reloadData()
                activityIndicator.stopAnimating()
                loadingPer.isHidden = true
            }
            isLoading = false
        }
    }
    
    @IBAction func fetchButton(_ sender: Any) {
        collectionView.reloadData()
        
        DispatchQueue.global().sync { [self] in
            setPhotoLibraryImage()
        }
    }
    
    // 범위 지정 뷰 띄우기
    @IBAction func optionButton(_ sender: Any) {
        
    }
    
    
    // MARK: - Public Variable
    public var results: [PHAsset] = []
    public var fetchPhotos: PHFetchResult<PHAsset>?
    public var index: Int?
    public let fileManager = FileManager.default
    
    // MARK: - Save to CoreData
    func saveImageToLocal(image: UIImage) {
        DispatchQueue.main.sync {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let photo = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context)
            let png = UIImageJPEGRepresentation(image, 1.0)
            photo.setValue(png, forKey: "image")
            
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Fetch to CoreData
    func fetchContact() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            let contact = try context.fetch(Contact.fetchRequest())
            if let photo = contact.last {
                print(UIImage(data: photo.image!)!)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Private Variable
    public let label = UILabel()
    public var barcodeDatas: [UIImage] = []
    public var loading = 0
    public var isLoading = false
    
    // MARK: - Loading Animation Indicator
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.white
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    // MARK: - 이미지 스캔
    func scanImage(data: Data, photo: PHAsset) {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: { [self] request, error in
            self.reportResults(results: request.results, data: data, photo: photo)
            
        })
        let handler = VNImageRequestHandler(data: data, options: [.properties: ""])
        
        guard let _ = try? handler.perform([barcodeRequest]) else {
            return print("Could not perform barcode-request!")
        }
    }
    
    // MARK: - 스캔 결과
    func reportResults(results: [Any]?, data: Data, photo: PHAsset) {
        var check = false
        // Loop through the found results
        guard let results = results else {
            return print("No results found.")
        }
        
        for result in results {
            // Cast the result to a barcode-observation
            if let barcode = result as? VNBarcodeObservation {
                
                if let payload = barcode.payloadStringValue {
                    print("Payload: \(payload)")
                }
                
                // Print barcode-values
                print("Symbology: \(barcode.symbology.rawValue)")
                // QRCode 제외
                if barcode.symbology.rawValue == "VNBarcodeSymbologyCode128"{
                    check = true
                }
                
                if let desc = barcode.barcodeDescriptor as? CIQRCodeDescriptor {
                    let content = String(data: desc.errorCorrectedPayload, encoding: .utf8)
                    
                    // FIXME: This currently returns nil. I did not find any docs on how to encode the data properly so far.
                    print("Payload: \(String(describing: content))")
                    print("Error-Correction-Level: \(desc.errorCorrectionLevel)")
                    print("Symbol-Version: \(desc.symbolVersion)")
                }
            }
        }
        
        // 바코드인 경우
        if results.count > 0 && check{
            print("바코드 확인")
            barcodeDatas.append(UIImage(data: data)!)
            self.results.append(photo)
            // saveImageToLocal(image: UIImage(data: data)!)
        }
    }
    
    
    // MARK: - Set Loading Text
    func setText(){
        loadingPer.text = String(format: "%.1f", (Double(loading) / Double(fetchPhotos!.count) * 100)) + "%"
    }
    
    func endLoading(count: Int, photos: Int) {
        if count >= photos {
            collectionView.reloadData()
            activityIndicator.stopAnimating()
            loadingPer.isHidden = true
            isLoading = false
        }
    }
    
    // MARK: - PHAsset to UIImage Function
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.deliveryMode = .highQualityFormat
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 550, height: 550), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            if let result = result{
                thumbnail = result
            }
        })
        return thumbnail
    }
}
// MARK: - ViewController Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.activityIndicator)
        reloadBtn.setTitle("", for: .normal)
        optionBtn.setTitle("", for: .normal)
        
        loadingPer.text = "0"
        
        loadingPer.isHidden = true
        loadingLabel.isHidden = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized: break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized: break
                case .notDetermined: break
                case .restricted: break
                case .denied: break
                case .limited: break
                @unknown default: break
                }
            }
        case .denied: break
        case .limited: break
        case .restricted: break
        @unknown default:
            fatalError()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = index{
            barcodeDatas.remove(at: index)
            results.remove(at: index)
        }
        label.isHidden = true
        
        fetchContact()
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.preferredContentSize = CGSize(width: 300, height: 150)
        if let presentationController = segue.destination.popoverPresentationController {
            presentationController.delegate = self
        }
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
