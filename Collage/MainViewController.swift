import UIKit
import Combine

class MainViewController: UIViewController {
    // MARK: - Combine
    
    private var subscriptions = Set<AnyCancellable>()
    private let images = CurrentValueSubject<[UIImage], Never>([])
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var imagePreview: UIImageView! {
        didSet {
            imagePreview.layer.borderColor = UIColor.gray.cgColor
        }
    }
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    // MARK: - Private properties
    
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collageSize = imagePreview.frame.size
        
        // 1 You begin a subscription to the current collection of photos.
        images
            
            .print()
            .handleEvents(receiveOutput: { [weak self] photos in
                self?.updateUI(photos: photos)
            })
            // 2 Use map to convert them to a single collage by calling into UIImage.collage(images:size:), a helper method defined in UIImage+Collage.swift.
            .map { photos in
                UIImage.collage(images: photos, size: collageSize)
            }
            // 3 Use the assign(to:on:) subscriber to bind the resulting collage image to imagePreview.image, which is the center screen image view.
            .assign(to: \.image, on: imagePreview)
            // 4 store the resulting subscription into subscriptions to tie its lifespan to the view controller if it's not canceled earlier than the controller.
            .store(in: &subscriptions)
        
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    // MARK: - Actions
    
    @IBAction func actionClear() {
        images.send([])
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        
        // 1 You subscribe the PhotoWriter.save(_) future by using sink(receiveCompletion:receiveValue:).
        PhotoWriter.save(image)
            .sink(receiveCompletion: { [unowned self] completion in
                // 2 In case of completion with a failure, you call into showMessage(_:description:) to display an error alert on-screen.
                if case .failure(let error) = completion {
                    self.showMessage("Error", description: error.localizedDescription)
                }
                self.actionClear()
            }, receiveValue: { [unowned self] id in
                // 3 In case you get back a value — the new asset id — you use showMessage(_:description:) to let the user know their collage is saved successfully.
                self.showMessage("Saved with id: \(id)") })
            .store(in: &subscriptions)
    }
    
    @IBAction func actionAdd() {
        print("Images: \(images.value.count)")
//        let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
//        images.send(newImages)
        
        let photos = storyboard!.instantiateViewController( withIdentifier: "PhotosViewController") as! PhotosViewController
        
//        photos.$selectedPhotosCount
//            .print("$selectedPhotosCount ")
//            .filter { $0 > 0 }
//            .map { "Selected \($0) photos" }
//            .assign(to: \.title, on: self)
//            .store(in: &subscriptions)
        
        
        let newPhotos = photos.selectedPhotos
            .prefix(while: { [unowned self] _ in
                return self.images.value.count < 6
            })
            .filter { newImage in
                return newImage.size.width > newImage.size.height
            }//filter all images with portrait orientation.
            .share()
        
        
        newPhotos
            .ignoreOutput()
            .filter { [unowned self] _ in self.images.value.count == 6 }
            .print("HOLA")
            .flatMap { [unowned self] _ in
                self.alert(title: "Limit reached", text: "To add more than 6 photos please purchase Collage Pro")
            }
            .print("HOLA1")
            .sink(receiveCompletion: { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }, receiveValue: { _ in          })
            .store(in: &subscriptions)
        
        
        
        //let newPhotos = photos.selectedPhotos
        //let newPhotos = photos.selectedPhotos.share()
        newPhotos
            .map { [unowned self] newImage in // 1
                return self.images.value + [newImage] }
            // 2
            .assign(to: \.value, on: images)
            // 3
            .store(in: &subscriptions)

        
        newPhotos
            .ignoreOutput()
            .delay(for: 2.0, scheduler: DispatchQueue.main)
            .sink(receiveCompletion: { [unowned self] _ in
                print("receiveCompletion updateUI")
                self.updateUI(photos: self.images.value)
            }, receiveValue: { _ in })
            .store(in: &subscriptions)
        
        navigationController!.pushViewController(photos, animated: true)
    }
    
    private func showMessage(_ title: String, description: String? = nil) {
//        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { alert in
//            self.dismiss(animated: true, completion: nil)
//        }))
//        present(alert, animated: true, completion: nil)
        
        alert(title: title, text: description)
            .sink(receiveValue: { _ in
                    //print("ReceiveValue")
                
            })
            .store(in: &subscriptions)
        
    }
}
