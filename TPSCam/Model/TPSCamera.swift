//
//  TPSCamera.swift
//  TPSCamDemo
//
//  Created by The Power of Swift. on 4/18/17.
//  Copyright © 2017 The Power of Swift. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

public protocol TPSCameraDelegate: class {
    func camera(_ camera: TPSCamera, didOutputSampleBufferImage ciImage: CIImage?)
}

public class TPSCamera: NSObject {

    // MARK: - Properties
    
    weak var delegate: TPSCameraDelegate?
    
    fileprivate let superView: UIView
    fileprivate let sessionQueue: DispatchQueue
    
    fileprivate var eaglContext: EAGLContext!
    fileprivate var captureSession: AVCaptureSession!
    
    fileprivate var glkPreviewView: GLKView!
    fileprivate var cameraImage: CIImage?
    fileprivate var ciContext: CIContext!
    
    
    // MARK: - Initializers
    
    public init(superView: UIView) {
        self.superView = superView
        self.sessionQueue = DispatchQueue(label: "com.ThePowerofSwift.TPSCam", attributes: []) ///DispatchQueue(label: "com.ThePowerofSwift.TPSCam")
        self.eaglContext = EAGLContext(api: .openGLES2)
        self.captureSession = AVCaptureSession()
        self.ciContext = CIContext(eaglContext: self.eaglContext!)
        self.glkPreviewView = GLKView(frame: superView.bounds)
        
        super.init()
        superView.addSubview(glkPreviewView)
        glkPreviewView.context = eaglContext!
        glkPreviewView.delegate = self
        glkPreviewView.bindDrawable()
        
        self.prepareCamera()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        // MARK: - Clear garbage
        
        self.eaglContext = nil
        self.captureSession = nil
        self.glkPreviewView = nil
    }
}


// MARK: - Helper Methods

extension TPSCamera {
    
    public func startSession() {
        if let captureSession = captureSession {
            if !captureSession.isRunning {
                sessionQueue.async {
                    captureSession.startRunning()
                }
            }
        }
    }
    
    public func stopSesion() {
        if let captureSession = captureSession {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }
    
    public func cameraLayoutSubviews() {
        glkPreviewView.frame = superView.bounds
    }
    
    fileprivate func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        guard let backCamera = (AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]).filter({ $0.position == .back }) .first else {
            fatalError("Unable to access front camera")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            fatalError("Unable to add input")
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    
    fileprivate func processImage(_ cameraImage: CIImage) -> CIImage {
        // TODO: - Process image
        
        
        
        return cameraImage
    }
}


// MARK: - GLKViewDelegate

extension TPSCamera: GLKViewDelegate {
    
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        guard let cameraImage = cameraImage else {
            return
        }
        
        let outputImage = processImage(cameraImage)
        
        let aspect = cameraImage.extent.width / cameraImage.extent.height
        
        let targetWidth = aspect < 1 ?
            Int(CGFloat(glkPreviewView.drawableHeight) * aspect) :
            glkPreviewView.drawableWidth
        
        let targetHeight = aspect < 1 ?
            glkPreviewView.drawableHeight :
            Int(CGFloat(glkPreviewView.drawableWidth) / aspect)
        
        ciContext.draw(outputImage, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight), from: outputImage.extent)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension TPSCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.camera(self, didOutputSampleBufferImage: self.cameraImage)
            self.glkPreviewView.setNeedsDisplay()
        }
    }
}
