
import AVFoundation
import RxSwift
import RxCocoa

@objc(CameraViewController)
class CameraViewController: UIViewController{
    var cameraMasterViewModel = CameraMasterViewModel()
    var foundFace :BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var takePhoto = false
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession:BehaviorRelay<AVCaptureSession> = BehaviorRelay(value: AVCaptureSession())
    var sessionQueue :BehaviorRelay<DispatchQueue> = BehaviorRelay(value: DispatchQueue(label: Constant.sessionQueueLabel))
    private var lastFrame: CMSampleBuffer?
    var disposeBag = DisposeBag()
    
    private lazy var previewOverlayView: UIImageView = {
        precondition(isViewLoaded)
        let previewOverlayView = UIImageView(frame: .zero)
        previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
        previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return previewOverlayView
    }()
    
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    @IBOutlet private weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraMasterViewModel.foundFace.bind(to: foundFace).disposed(by: disposeBag)
        cameraMasterViewModel.previewOverlayImage.bind(to: previewOverlayView.rx.image).disposed(by: disposeBag)
        captureSession.bind(to: cameraMasterViewModel.captureSession).disposed(by: disposeBag)
        sessionQueue.bind(to: cameraMasterViewModel.sessionQueue).disposed(by: disposeBag)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession.value)
        setupUI()
        cameraMasterViewModel.setUpCaptureSessionInput()
        cameraMasterViewModel.setUpCaptureSessionOutput(delegate: self)
        observeOnAlert()
        observeWhenImageCaptured()
    }
    
    func setupUI(){
        setUpPreviewOverlayView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraMasterViewModel.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraMasterViewModel.stopSession()
    }
    

    
    private func setUpPreviewOverlayView() {
        cameraView.addSubview(previewOverlayView)
        NSLayoutConstraint.activate([
            previewOverlayView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
            previewOverlayView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
            previewOverlayView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            previewOverlayView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
            
        ])
        
    }
    @IBAction func captureImageClicked(_ sender: Any) {
        cameraMasterViewModel.canTakePhoto.accept(true)
    }
    
    func observeOnAlert(){
        cameraMasterViewModel.makeErrorAlert.filter{$0}.asObservable().observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [unowned self] (makeErrorAlert) in
            
            makeAlert(title: "No Face Detected", message: "Please capture image with your face and try again", preferedStyle: .alert, buttonTitle: "Ok")
            cameraMasterViewModel.makeErrorAlert.accept(false)

        }).disposed(by: disposeBag)
    }
    
    func observeWhenImageCaptured(){
        cameraMasterViewModel.capturedImage.asObservable().observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [unowned self] (image) in
            DispatchQueue.main.async {
                if let photoVC = self.storyboard?.instantiateViewController(withIdentifier: Constant.PhotoViewController) as? PhotoViewController{
                    photoVC.image = image
                    self.present(photoVC, animated: true, completion: nil)
                }
            }
        }).disposed(by: disposeBag)
    }

    
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        cameraMasterViewModel.captureOutput(sampleBuffer: sampleBuffer)
    }
    
}




