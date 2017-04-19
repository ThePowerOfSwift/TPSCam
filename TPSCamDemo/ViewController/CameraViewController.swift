//
//  CameraViewController.swift
//  TPSCamDemo
//
//  Created by The Power of Swift. on 4/18/17.
//  Copyright © 2017 The Power of Swift. All rights reserved.
//

import UIKit
import TPSCam

class CameraViewController: UIViewController {

    // MARK: - Properties
    
    fileprivate var videoCamera: TPSCamera!
    
    
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        videoCamera = TPSCamera(superView: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCamera.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCamera.stopSesion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoCamera.cameraLayoutSubviews()
    }
}
