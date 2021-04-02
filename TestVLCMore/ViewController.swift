//
//  ViewController.swift
//  TestVLCMore
//
//  Created by Shane Whitehead on 2/4/21.
//

import UIKit
import MobileVLCKit

//extension VLCLibrary {
//	static let fastRTSP: VLCLibrary = {
//		var options = [Any]()
//		options.append("--rtsp-tcp")
//		return VLCLibrary(options: options)
//	}()
//}

extension VLCMediaPlayer {

	func setCropRatio(numerator: UInt, denominator: UInt) {
		let value = "\(numerator):\(denominator)"
		videoCropGeometry = UnsafeMutablePointer<Int8>(mutating: (value as NSString).utf8String)
	}
	
}

extension VLCMediaPlayerState: CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .stopped: return "stopped"
		case .opening: return "opening"
		case .buffering: return "buffering"
		case .ended: return "ended"
		case .error: return "error"
		case .playing: return "playing"
		case .paused: return "paused"
		case .esAdded: return "esAdded"
		@unknown default: return "---"
		}
	}
	
}

class ViewController: UIViewController {
	
	@IBOutlet var startButton: UIButton!
	@IBOutlet var stopButton: UIButton!
	
	@IBOutlet var seperatorView: UIView!
	
	let sources: [URL] = [
		// List of playable URLS.  on a iPhoneX, should be able to support 8 comformatably
	]
	
	var videoViews: [VideoPlayerView] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		startButton.setTitle("Start all", for: [])
		stopButton.setTitle("Stop all", for: [])
		
		startButton.backgroundColor = .systemGray6
		stopButton.backgroundColor = .systemGray6
	}

	@IBAction func startAll(_ sender: Any) {
		guard videoViews.isEmpty else { return }
		
		var yAnchor = view.safeAreaLayoutGuide.topAnchor
		var xAnchor = view.leadingAnchor
		
		var column = 1
		for source in sources {
			let videoPlayer = VideoPlayerView()
			videoPlayer.contentSource = source
			
			videoViews.append(videoPlayer)
			
			view.addSubview(videoPlayer)
			NSLayoutConstraint.activate([
				videoPlayer.leadingAnchor.constraint(equalTo: xAnchor),
				videoPlayer.topAnchor.constraint(equalTo: yAnchor),
				videoPlayer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
				videoPlayer.heightAnchor.constraint(equalTo: videoPlayer.widthAnchor, multiplier: 0.75)
			])
			
			if column.isMultiple(of: 2) {
				yAnchor = videoPlayer.bottomAnchor
				xAnchor = view.leadingAnchor
			} else {
				xAnchor = videoPlayer.trailingAnchor
			}
			column += 1
		}
		
		for player in videoViews {
			player.startPlayback()
		}
		
		view.layoutIfNeeded()
	}
	
	@IBAction func stopAll(_ sender: Any) {
		guard !videoViews.isEmpty else { return }
		
		print("Stop all players")
		videoViews.forEach { (player) in
			player.stopPlayback()
		}
		print("Remove all players")
		videoViews.forEach { (player) in
			player.removeFromSuperview()
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			print("Dispose of all players")
			self.videoViews.forEach { (player) in
				player.dispose()
			}
			print("Empty view cache")
			self.videoViews.removeAll()
		}
		
		view.layoutIfNeeded()
	}
}
//
////	let mediaURL = URL(string: "rtsp://192.168.86.150/av0_1")!
//
//	@IBOutlet weak var playerView: VideoPlayerView!
////
////	lazy var player: VLCMediaPlayer = {
////		let player = VLCMediaPlayer(library: VLCLibrary.swann)!
////		return player
////	}()
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		playerView.contentSource = URL(string: "rtsp://192.168.86.150/av0_1")
//
////		player.delegate = self
////		player.drawable = renderView
////		//player.videoCropGeometry = "4:3"
////
////		// Could make this an extentions to make it easier
////		//player.videoCropGeometry = UnsafeMutablePointer<Int8>(mutating: ("4:3" as NSString).utf8String)
////		player.setCropRatio(numerator: 4, denominator: 3)
////		player.media = VLCMedia(url: mediaURL)
////
////		player.audio.isMuted = true
//	}
//
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//
//		playerView.startPlayback()
////
////		player.play()
//	}
//
//}
////
////extension ViewController: VLCMediaPlayerDelegate {
////
////	func mediaPlayerSnapshot(_ aNotification: Notification!) {
////		print("mediaPlayerSnapshot")
////	}
////
////	func mediaPlayerTimeChanged(_ aNotification: Notification!) {
////		print("mediaPlayerTimeChanged \(player.time.verboseStringValue)/\(player.remainingTime.verboseStringValue)")
////
////
////	}
////
////	func mediaPlayerStateChanged(_ aNotification: Notification!) {
////		print("mediaPlayerStateChanged \(player.state.debugDescription)")
////	}
////
////	func mediaPlayerTitleChanged(_ aNotification: Notification!) {
////		print("mediaPlayerTitleChanged")
////	}
////
////	func mediaPlayerChapterChanged(_ aNotification: Notification!) {
////		print("mediaPlayerChapterChanged")
////	}
////
////	func mediaPlayerLoudnessChanged(_ aNotification: Notification!) {
////		//print("mediaPlayerLoudnessChanged")
////	}
////
////	func mediaPlayerStartedRecording(_ player: VLCMediaPlayer!) {
////		print("mediaPlayerStartedRecording")
////	}
////
////	func mediaPlayer(_ player: VLCMediaPlayer!, recordingStoppedAtPath path: String!) {
////		print("mediaPlayer recordingStoppedAtPath")
////	}
////}
