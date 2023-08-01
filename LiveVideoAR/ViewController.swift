//
//  ViewController.swift
//  LiveVideoAR
//
//  Created by Yusron Alfauzi on 30/06/23.
//

import UIKit
import RealityKit
import ARKit
import AVKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Starting Image Tracking
        startImageTracking()
        
        arView.session.delegate = self
    }
    
    func startImageTracking(){
        
        //image to track
//        guard let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
//            print("image not available, import one!")
//            return
//        }
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main){
            //configure image tracking
            let configuration = ARImageTrackingConfiguration()
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            
            //start session
            arView.session.run(configuration)
        } else {
            print("image not available, import one!")
            return
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            
            // image anchor?
            if let imageAnchor = anchor as? ARImageAnchor{
                
                // create video screen
                let width = Float(imageAnchor.referenceImage.physicalSize.width)
                let height = Float(imageAnchor.referenceImage.physicalSize.height)
                let videoScreen = createVideoScreen(width: width, height: height)
                
                //place screen onto the image anchor
                placevideoScreen(videoScreen: videoScreen, imageAnchor: imageAnchor)
            }
        }
    }
    
    //MARK: - Object placement
    func placevideoScreen(videoScreen: ModelEntity, imageAnchor: ARImageAnchor) {
        
        //anchor entity
        let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
        
        //roatte 90 degree in x axis
        let rotationAngle = simd_quatf(angle: GLKMathDegreesToRadians(-90), axis: SIMD3(x: 1, y: 0, z: 0))
        videoScreen.setOrientation(rotationAngle, relativeTo: imageAnchorEntity)
        
        //position the screen to the side
        let bookWidth = imageAnchor.referenceImage.physicalSize.width
        videoScreen.setPosition(SIMD3(x: Float(bookWidth), y: 0, z: 0), relativeTo: imageAnchorEntity)
        
        //attach model to anchor
        imageAnchorEntity.addChild(videoScreen)
        
        //add anchor to scene
        arView.scene.addAnchor(imageAnchorEntity)
    }
    
    //MARK: - video screen
    
    func createVideoScreen(width: Float, height: Float) -> ModelEntity {
        
        //mesh
        let screenMesh = MeshResource.generatePlane(width: width, height: height)
        
        //video material
        let videoItem = createVideoitem(with: "romanticvideo")
        let videoMateriL = createVideoMaterial(with: videoItem!)
        
        //model entity
        let videoScreenModel = ModelEntity(mesh: screenMesh, materials: [videoMateriL])
        return videoScreenModel
    }

    func createVideoitem(with fileName: String) -> AVPlayerItem? {
        
        //url
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") else {return nil}
        
        //videoItem
        let asset = AVURLAsset(url: url)
        let videoItem = AVPlayerItem(asset: asset)
        
        return videoItem
    }
    
    func createVideoMaterial(with videoItem: AVPlayerItem) -> VideoMaterial {
        
        //video player
        let player = AVPlayer()
        
        //video material
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        //play video
        player.replaceCurrentItem(with: videoItem)
        player.play()
        
        return videoMaterial
    }
}
