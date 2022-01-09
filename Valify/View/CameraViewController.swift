
import AVFoundation
import RxSwift
import RxCocoa
import Vision
import UIKit
import Alamofire
import CoreMotion

enum ImagePlace {
    case top
    case middle
    case bottom
    case topMiddle
    case bottomMiddle
}

@objc(CameraViewController)
class CameraViewController: UIViewController{
    
    
    
    @IBOutlet weak var successImageview: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var idImgaeOverley: UIView!
    var cameraMasterViewModel = CameraMasterViewModel()
    var foundFace :BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var isUsingFrontCamera = false
    private var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var captureSession:BehaviorRelay<AVCaptureSession> = BehaviorRelay(value: AVCaptureSession())
    var sessionQueue :BehaviorRelay<DispatchQueue> = BehaviorRelay(value: DispatchQueue(label: Constant.sessionQueueLabel))
    var disposeBag = DisposeBag()
    @IBOutlet weak var idImage: UIImageView!
    private var captureSessionManager: CaptureSessionManager?
    var startCaptureImages = false
    var imagesArray = [UIImage]()
    var stepNumber : Int!
    var openTourch = true
    var captureTimer :Timer!
    var stable : AVCaptureVideoStabilizationMode!
    @IBOutlet weak var previewOverlayView: UIImageView!
    var accuracyCorrectForRectangle = 0
    var accuracyInCorrectForRectangle = 0
    var repeatTimer = true
    var imagePlace:ImagePlace!
    var tourch = true
    var lastImage :  UIImage?
    var noRectsFlag = true
    var withTimeInterval = 2.0
    var bufferCounter = 0
    var startDetectingNoNIDRemoved = false
    var numberOfNORectagleFrames = 0
    var numberOfRectagleFrames = 0
    var numberOfRectangelsFrameCounter = 0
    var stopSession = false
    var motion = CMMotionManager()
    var timer = Timer()
    var nidPlaces : [ImagePlace]!
    var firstHit = true
    var lastStepIndex = -1
    var flashEnabled =  true
//    var toast:UILabel!
    @IBOutlet weak var toast: UILabel!
    let concurrentQueue = DispatchQueue(label: "com.test.concurrent", attributes: .concurrent)
    let myGroup = DispatchGroup()
    var captureStared = false
    var framesCounter = 0
//    let semaphore = DispatchSemaphore(value: 0)
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    private var bBoxLayer = CAShapeLayer()
    @IBOutlet weak var frameForIdBottomConstraint: NSLayoutConstraint!
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    private var player: AVAudioPlayer?
    @IBOutlet weak var autoFlashBtn: UIButton!
    
    @IBOutlet weak var offFlashBtn: UIButton!
    
    @IBOutlet weak var onFlashBtn: UIButton!
    @IBOutlet private weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelAllRequests()
        OCRData.clearStaticData()
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer)
        captureSessionManager?.delegate = self
        switch ValifyInit.shared.watermarkType {
        case .backCapture:
            nidPlaces = [.middle]
            goToNextImage()
        case .frontCapture:
            nidPlaces = randomPlacesForNid()
            goToNextImage()
        case .none:
            break
        }
        
        setupUI()
        captureSessionManager?.imageView = idImage

    }
    
    func playSound(){
        guard let url = Bundle.main.url(forResource: "SuccessSFX", withExtension: "mp3") else {
            print("MP3 resource not found.")
            return
        }

        print("Music to play : \(String(describing: url))")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }

    }
    
    @objc func flashAuto(){
//        print("Auto")
        CaptureSession.current.openFlash()
        captureSessionManager?.autoFlash = true
    }
    
    @objc func flashOff(){
//        print("OFF")
        CaptureSession.current.turnOffFlash { [unowned self] turnedOff in
            captureSessionManager?.autoFlash = false
        }
    }
    
    @objc func flashOn(){
//        print("ON")
        CaptureSession.current.openFlash()
        captureSessionManager?.autoFlash = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        DispatchQueue.main.async { [self] in
            captureSessionManager?.start()
        }
        CaptureSession.current.isEditing = false
    }
    
    func setupUI(){
//        successImageview.isHidden = true
//        successImageview.image = UIImage(named: "success")
        loadingIndicator.isHidden = true
        successImageview.isHidden = true
        idImage.contentMode = .scaleAspectFit
        switch ValifyInit.shared.watermarkType {
        case .backCapture:
            idImage.image = UIImage(named: "id empty")
        case .frontCapture:
            idImage.image = UIImage(named: "id empty")
            
//            idImage.image = UIImage(named: "id front")
        case .none:
            break
        }
        
        idImage.isHidden = false
        view.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        let previewView = UIView(frame: view.frame)
        self.cameraView.addSubview(previewView)
        previewView.layer.addSublayer(videoPreviewLayer)
        cameraView.addSubview(previewView)
        cameraView.bringSubviewToFront(idImage)
        cameraView.sendSubviewToBack(previewView)
        
        let button = UIButton(frame: CGRect(x: 16, y: 40, width: 80, height: 44))
        button.setTitle("Restart", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(boomButtonTouchedUpInside), for: .touchUpInside)
        view.addSubview(button)
        
        let autoFlash = UIButton(frame: CGRect(x: 100, y: 40, width: 80, height: 44))
        autoFlash.setTitle("Auto", for: .normal)
        autoFlash.setTitleColor(.white, for: .normal)
        autoFlash.addTarget(self, action: #selector(flashAuto), for: .touchUpInside)
//        view.addSubview(autoFlash)
        
        let offFlash = UIButton(frame: CGRect(x: 150, y: 40, width: 80, height: 44))
        offFlash.setTitle("Off", for: .normal)
        offFlash.setTitleColor(.white, for: .normal)
        offFlash.addTarget(self, action: #selector(flashOff), for: .touchUpInside)
//        view.addSubview(offFlash)
        
        let onflash = UIButton(frame: CGRect(x: 200, y: 40, width: 80, height: 44))
        onflash.setTitle("On", for: .normal)
        onflash.setTitleColor(.white, for: .normal)
        onflash.addTarget(self, action: #selector(flashOn), for: .touchUpInside)
//        view.addSubview(onflash)
        
//        toast = UILabel(frame: CGRect(x: 5, y: 20, width: screenWidth - 10, height: 44))
//        toast.backgroundColor = .black
//        toast.textColor = .white
//        toast.numberOfLines = 2
//        message.setTitle("On", for: .normal)
//        message.setTitleColor(.white, for: .normal)
//        message.addTarget(self, action: #selector(flashOn), for: .touchUpInside)
//        view.addSubview(toast)
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer.frame = view.layer.bounds
    }
    
    
    func handelIDcardInMiddle(){
//        resetTimer()
        let previewHeight = UIScreen.main.bounds.height
        let idImageHeight = idImage.bounds.height
        let x = (previewHeight / 2) - (idImageHeight / 2)
        self.frameForIdBottomConstraint.constant = x
        UIView.animate(withDuration: 0.7) { [weak self] in
          self?.view.layoutIfNeeded()
        }
//        semaphore.signal()
        
    }
    
    func cancelAllRequests(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    
    @objc func boomButtonTouchedUpInside(_ sender: Any) {
        captureSession.value.commitConfiguration()
//        repeatTimer = false
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach({$0.cancel()})
        }
//        if captureTimer != nil{
//            captureTimer.invalidate()
//            captureTimer = nil
//        }
//        delegate.restart()
//        dismiss(animated: true, completion: nil)
        let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        root?.dismiss(animated: true, completion: nil)

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CaptureSession.current.openFlash()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        imagesArray = []
        captureSessionManager?.stop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSessionManager?.stop()
    }
    
}


extension CameraViewController{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touch")
        
        guard  let touch = touches.first else { return }
        let touchPoint = touch.location(in: view)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        print("Touch Point: ",touchPoint)
        
        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            return
        }
    }
    func setTimerForDetectingRectangleAccuracy(){
        let total = accuracyCorrectForRectangle + accuracyInCorrectForRectangle
        if total != 0 {
           let accuracy = Double(accuracyCorrectForRectangle) / Double(total ) * 100
           print("accuracy ",accuracy)
           if accuracy > 50 {
               capture()
           }
        }
        framesCounter = 0
//        resetTimer()
//        captureTimer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: repeatTimer) { [self] (t) in
//            let total = accuracyCorrectForRectangle + accuracyInCorrectForRectangle
//            if total != 0 {
//                let accuracy = (accuracyCorrectForRectangle / total ) * 100
//                print("accuracy ",accuracy)
//                if accuracy > 50 {
//                    capture()
//                }
//            }
            accuracyCorrectForRectangle = 0
            accuracyInCorrectForRectangle = 0
//        }
    }
    
    func resetTimer(){
//        accuracyCorrectForRectangle = 0
//        accuracyInCorrectForRectangle = 0
//        bufferCounter = 0
//        print("Timer Start")
//        if captureTimer != nil{
//            captureTimer.invalidate()
//            captureTimer = nil
//        }
    }
    
    func capture(){
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        successImageview.isHidden = false
        playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            successImageview.isHidden = true
            
            captureSessionManager?.capturePhoto(imagePlace: imagePlace)
            
        }
        
        
        
        
        
    }
    
    
    func randomPlacesForNid() -> [ImagePlace]{
        var firstPlacesArr: [ImagePlace] = [.middle,.top,.bottom]
        let randomInt = Int.random(in: 0..<2)
        let secondPlacesArr: [ImagePlace] = [.bottomMiddle,.topMiddle]
        firstPlacesArr.append(secondPlacesArr[randomInt])
        firstPlacesArr.shuffle()
        print("First Array count: ", firstPlacesArr.count)
        return firstPlacesArr
    }
    
    func getNextStep() -> ImagePlace?{
        lastStepIndex += 1
        if lastStepIndex >= (nidPlaces.count){
            return nil
        }
        try? CaptureSession.current.resetFocusToAuto()
        CaptureSession.current.set(exposure: .min)
        return nidPlaces[lastStepIndex]
        
    }
    
    func goToNextImage(){
        
        DispatchQueue.main.async { [self] in
            switch getNextStep(){
            case .middle:
                handelIDcardInMiddle()
                imagePlace = .middle
                openTourch = true
//                print("Type: Middle")
            case .top:
                movecardToTopManual()
                imagePlace = .top
//                print("Type: Top")
            case .bottom:
                moveCardToBottomManual()
                imagePlace = .bottom
//                print("Type: Bottom")
            case .topMiddle:
                movecardToTopMiddleManual()
                imagePlace = .topMiddle
//                print("Type: TopMiddle")
            case .bottomMiddle:
                movecardToBottomMiddleManual()
                imagePlace = .bottomMiddle
//                print("Type: BottomMiddle")
            case .none:
                captureSessionManager?.stop()
                
                CaptureSession.current.turnOffFlash { turnedOff in
                    
                }
                self.showResults(watermarkType: ValifyInit.shared.watermarkType!)
                return
            }
//            semaphore.wait()
//            successImageview.isHidden = true
            captureSessionManager?.imageView = idImage
            changeIdImageOverlayColor(idOverlayColor:.grey)
//            setTimerForDetectingRectangleAccuracy()
        }
        
    }
    
    func movecardToTopManual(){
//        resetTimer()
        let screenHeight = screenHeight
        let idcardHeight = idImage.frame.height
        let spaceNeeded = screenHeight - ( idcardHeight + 40)
        self.frameForIdBottomConstraint.constant =  spaceNeeded
        UIView.animate(withDuration: 0.7) { [weak self] in
          self?.view.layoutIfNeeded()
        }
//        semaphore.signal()
        
        
    }
    func movecardToTopMiddleManual(){
//        resetTimer()
        let previewHeight = screenHeight
        let idImageHeight = idImage.bounds.height
        let x = (previewHeight / 2) - (idImageHeight / 2)
        self.frameForIdBottomConstraint.constant = x + 100
        UIView.animate(withDuration: 0.7) { [weak self] in
          self?.view.layoutIfNeeded()
        }
//        semaphore.signal()
        
    }
    func movecardToBottomMiddleManual(){
//        resetTimer()
        let const = screenHeight / 5
        self.frameForIdBottomConstraint.constant = const
        UIView.animate(withDuration: 0.7) { [weak self] in
          self?.view.layoutIfNeeded()
        }
//        semaphore.signal()
        
    }
    
    func moveCardToBottomManual(){
//        resetTimer()
        self.frameForIdBottomConstraint.constant = 50
        UIView.animate(withDuration: 0.7) { [weak self] in
          self?.view.layoutIfNeeded()
        }
//        semaphore.signal()
        
    }
    
    func moveCardToTheTop(withAnimation:Bool){
        let screenHeight = UIScreen.main.bounds.height
        let spaceNeeded = screenHeight - (self.frameForIdBottomConstraint.constant + 300 + 40)
        self.frameForIdBottomConstraint.constant = self.frameForIdBottomConstraint.constant +  spaceNeeded
        UIView.animate(withDuration: Double(ValifyInit.shared.upwardSpeed ?? 4), delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            self.moveCardToTheBottom(withAnimation: withAnimation)
        })
    }
    
    func moveCardToTheBottom(withAnimation:Bool){
        self.frameForIdBottomConstraint.constant = 15
        UIView.animate(withDuration: Double(ValifyInit.shared.downwardSpeed ?? 8), delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            self.showResults(watermarkType: ValifyInit.shared.watermarkType!)
        })
        
    }
    
    
    
    func showResults(watermarkType:WatermarkType){
        var images = [UIImage]()
        
        switch watermarkType {
        case .backCapture:
            OCRData.responseCount = 1
        case .frontCapture:
            OCRData.responseCount = 3
        }
        images = imagesArray
        captureSessionManager?.stop()
        if let imagesVC = self.storyboard?.instantiateViewController(withIdentifier: Constant.dataFromIDVC) as? DataFromIDVC{
            //        if let imagesVC = self.storyboard?.instantiateViewController(withIdentifier: Constant.previewCapturedImagesVC) as? PreviewCapturedImagesVC{
            //            imagesVC.imagesArray = images
            imagesVC.modalPresentationStyle = .fullScreen
            self.present(imagesVC, animated: true, completion: nil)
        }
        
    }
    
    
}


extension CameraViewController: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, towNidsFound: Bool) {
        self.captureSessionManager?.stop()
        Alert.showAlertWithoutCancel(title: "There should only be one ID in the frame", message: "Press Ok To Restart", okButtonTitle: "Ok") { [self] in
            print("RESTART")
            ValifyInit.shared.delegate?.restartWatermark(watermarkType: ValifyInit.shared.watermarkType)
            dismiss(animated: true)
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, nidRemoved: Bool) {
        self.captureSessionManager?.stop()
        Alert.showAlertWithoutCancel(title: "Your ID has been removed.", message: "Press Ok To Restart", okButtonTitle: "Ok") { [self] in
            print("RESTART")
            ValifyInit.shared.delegate?.restartWatermark(watermarkType: ValifyInit.shared.watermarkType)
            dismiss(animated: true)
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, isNidFound: Bool,message:String?) {
            framesCounter += 1
//            print("framesCounter: ", framesCounter)
            if framesCounter == 10{
                setTimerForDetectingRectangleAccuracy()
            }
            if isNidFound {
                if noRectsFlag {
//                    setTimerForDetectingRectangleAccuracy()
                    noRectsFlag = false
                }
                //            loading.resume()
                accuracyCorrectForRectangle += 1
                DispatchQueue.main.async { [unowned self] in
                    toast.text = "Capturing... \nPlease hold still"
                    changeIdImageOverlayColor(idOverlayColor:.green)
                }
                loadingIndicator.startAnimating()
                loadingIndicator.isHidden = false
                
            }else{
                DispatchQueue.main.async { [unowned self] in
                    changeIdImageOverlayColor(idOverlayColor:.grey)
                    toast.text = message ?? ""
                }
                loadingIndicator.stopAnimating()
                loadingIndicator.isHidden = true
                noRectsFlag = true
                accuracyInCorrectForRectangle += 1
            }

    }
    
    enum IdOverlayColor{
        case grey
        case green
    }
    
    func changeIdImageOverlayColor(idOverlayColor:IdOverlayColor){
        switch idOverlayColor {
        case .grey:
            idImgaeOverley.backgroundColor = UIColor(red: 166/255, green: 166/255, blue: 166/255, alpha: 0.5)
        case .green:
            idImgaeOverley.backgroundColor = UIColor(red: 0, green: 153/255, blue: 0, alpha: 0.5)
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, image: UIImage?) {
        
        
        
        //        print("type: ",OCRData.getWatermarkPlace(imagePlace: imagePlace))
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage) {
        if captureSessionManager.stopCaptureImages{
            return
        }
        if imagePlace == .middle{
//            print("API Called: ", OCRData.getWatermarkPlace(imagePlace: imagePlace))
            cameraMasterViewModel.getDataFromImage(image: picture, idSide: ValifyInit.shared.watermarkType!, firstHit: firstHit, imagePlace: imagePlace)
            //            imagesArray.append(picture)
            goToNextImage()
            firstHit = false
            if captureSessionManager.autoFlash {
                CaptureSession.current.openFlash()
            }
            
        }else{
            if imagePlace == .topMiddle || imagePlace == .bottomMiddle{
                goToNextImage()
                firstHit = false
            }else{
                
//                print("API Called: ", OCRData.getWatermarkPlace(imagePlace: imagePlace))
                cameraMasterViewModel.getDataFromImage(image: picture, idSide: ValifyInit.shared.watermarkType!, firstHit: firstHit, imagePlace: imagePlace)
//                imagesArray.append(picture)
                goToNextImage()
                firstHit = false
            }
            
        }
        
        
        
    }
    
    
    
    
    
    
}










