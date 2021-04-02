//
//  VideoPlayerView.swift
//  TestVLCMore
//
//  Created by Shane Whitehead on 2/4/21.
//

import Foundation
import UIKit
import MobileVLCKit

class VideoPlayerView: UIView {

	internal var lastState: VLCMediaPlayerState = .stopped
	
	internal var mediaPlayer: VLCMediaPlayer?

	// This is transparent view which acts as a gesture trap
	fileprivate lazy var renderView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	fileprivate lazy var scrollView: UIScrollView = {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false

//		view.backgroundColor = .blue

		view.alwaysBounceVertical = false
		view.alwaysBounceHorizontal = false
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		
		view.bouncesZoom = false
		view.bounces = false

		view.decelerationRate = .fast
		
		view.minimumZoomScale = 1.0
		view.maximumZoomScale = 6.0
		view.zoomScale = 1
		view.delegate = self

		return view
	}()
	
	var playerState: VLCMediaPlayerState {
		guard let player = mediaPlayer else { return .stopped }
		if player.state == .esAdded {
			return .buffering
		} else if player.isPlaying {
			return .playing
		} else if player.willPlay {
			return .buffering
		}
		
		return player.state
//		didSet {
//			guard oldValue != playerState else { return }
//
//			// Try and preserve the error state, assume playback has stopped if error occurs
//			guard lastState != .error || (playerState == .opening || playerState == .playing) else { return }
//			lastState = playerState
////			callbackBasedOnCurrentState()
//		}
	}

	var isPaused: Bool {
		return playerState == .paused
	}
	
	var isPlaying: Bool {
		return playerState != .stopped
	}
	
	public var duration: TimeInterval? {
		guard let media = mediaPlayer?.media else { return nil }
		guard let milliseconds = media.length.value?.doubleValue else { return nil }
		return milliseconds / 1000.0
	}
	
	public var remainingTimeInterval: TimeInterval? {
		guard let remaining = mediaPlayer?.remainingTime else { return nil }
		guard let milliseconds = remaining.value else { return nil }
		return milliseconds.doubleValue / 1000.0
	}
	
	public var playedTimenterval: TimeInterval? {
		guard let time = mediaPlayer?.time, let milliseconds = time.value else { return nil }
		return milliseconds.doubleValue / 1000.0
	}

	public var playbackProgress: Double? {
		guard isPlaying else { return nil }
		guard let time = mediaPlayer?.time else { return nil }
		guard let timeValue = time.value else { return nil }
		guard let duration = self.duration else { return nil }
		
		let timeInSeconds = timeValue.doubleValue / 1000.0
		
		return timeInSeconds / duration
	}
	
	var contentSource: URL?
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	public init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		commonInit()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		commonInit()
	}
	
	fileprivate var isInitislised = false
	internal func commonInit() {
		guard !isInitislised else { return }
		isInitislised = true
		
		translatesAutoresizingMaskIntoConstraints = false
		
		backgroundColor = .systemGray6
		
		layer.borderWidth = 1
		layer.borderColor = UIColor.systemBlue.cgColor
		
		prepareRenderView()
	}
	
	func prepareRenderView() {
		// Setup render view

		scrollView.addSubview(renderView)
		
		renderView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
		renderView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
		renderView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		renderView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		renderView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		renderView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
		
		// Setup scrollview

		addSubview(scrollView)

		scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		scrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		scrollView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		scrollView.isUserInteractionEnabled = true
		scrollView.isMultipleTouchEnabled = true
	}
	
//	deinit {
//		mediaPlayer?.delegate = nil
//		mediaPlayer?.drawable = nil
//		mediaPlayer = nil
//	}
	
	func dispose() {
//		mediaPlayer?.delegate = nil
//		mediaPlayer?.drawable = nil
//		mediaPlayer = nil
		defer {
			mediaPlayer = nil
		}
		guard let player = mediaPlayer else { return }
		MediaPlayerFactory.shared.put(player)
	}
		
	func callbackBasedOnCurrentState() {
//		switch playerState {
//		case .ended: fallthrough
//		case .stopped: onPlaybackStopped?(self)
//		case .opening: onConnecting?(self)
//		case .buffering: onPlaybackBuffering?(self)
//		case .error: onPlaybackFailed?(self)
//		case .playing: onPlaybackStarted?(self)
//		case .paused: onPlaybackPaused?(self)
//		case .stopping: break
//		case .esAdded: streamWasAdded()
//		@unknown default:
//			fatalError("Unknown MediaPlayState: \(playerState)")
//		}
	}
	
	func createMediaPlayerIfRequired(url: URL) -> VLCMediaPlayer {
		if let player = mediaPlayer {
			return player
		}
		
		let player = MediaPlayerFactory.shared.get()
		
		player.delegate = self
		player.drawable = renderView
		//player.videoCropGeometry = "4:3"
		
		// Could make this an extentions to make it easier
		//player.videoCropGeometry = UnsafeMutablePointer<Int8>(mutating: ("4:3" as NSString).utf8String)
		player.setCropRatio(numerator: 4, denominator: 3)
		player.media = VLCMedia(url: url)
		
		// Should be derived from some kind of state
		player.audio.isMuted = true
		
		mediaPlayer = player
		
		return player
	}
	
	func startPlayback() {
		guard let contentSource = contentSource else { return }
		let player = createMediaPlayerIfRequired(url: contentSource)
		player.play()
	}
	
	func stopPlayback() {
//		print("[\(String(describing: contentSource))] isPlaying = \(isPlaying)")
//		print("[\(String(describing: contentSource))] state = \(playerState)")
		guard let player = mediaPlayer, isPlaying else { return }
		print("[\(String(describing: contentSource))] Stop playback")
		player.stop()
	}
	
	func resetZoom() {
		scrollView.zoomScale = 1
	}
	
	public var zoom: CGFloat {
		get {
			return CGFloat(mediaPlayer?.scaleFactor ?? 1.0)
		}
		
		set {
			// Need to calculate the scale factor based on the viewable bounds
			// This would make more sense from the perspetive of the
			// app, as it doesn't care about the video size itself and
			// everything is relative to viewable area
			mediaPlayer?.scaleFactor = Float(newValue)
		}
	}
	
	// MARK: - Zoom support
	
	var virtualOriginZoom: CGFloat {
		guard let player = mediaPlayer else { return 1.0 }
		let videoSize = player.videoSize
		guard videoSize.width > 0 && videoSize.height > 0 else { return 1.0 }
		
		let viewSize = bounds.size
		return max(viewSize.width / videoSize.width, viewSize.height / videoSize.height) + 0.2
	}
	
	// MARK: - Pinch
	
	var startingScaleFactor: CGFloat = 0
	var minimumScale: CGFloat {
		return virtualOriginZoom
	}
	var maximumScale: CGFloat {
		return virtualOriginZoom * 6.0 // 🤞
	}
//
//	@objc func wasDoubleTapped(_ gesture: UITapGestureRecognizer) {
//		//mediaPlayer.scaleFactor = 0
//		resetZoom()
//	}
	
	// MARK: - Gesture support
	
	public func toRenderViewAdd(gestureRecognizer: UIGestureRecognizer) {
		renderView.addGestureRecognizer(gestureRecognizer)
	}

	public func fromRenderViewRemove(gestureRecognizer: UIGestureRecognizer) {
		renderView.removeGestureRecognizer(gestureRecognizer)
	}
	
	func mediaStateDidChange() {
		guard lastState != playerState else { return }
		guard lastState != .error || (playerState == .opening || playerState == .playing) else { return }
		lastState = playerState
		print("[\(String(describing: contentSource))] playerState did change to \(playerState)")
	}

}

extension VideoPlayerView: UIScrollViewDelegate {
	
	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return renderView
	}

}

extension VideoPlayerView: VLCMediaPlayerDelegate {
	
	func mediaPlayerSnapshot(_ aNotification: Notification!) {
		print("[\(String(describing: contentSource))] mediaPlayerSnapshot")
	}
	
	func mediaPlayerTimeChanged(_ aNotification: Notification!) {
		guard let player = mediaPlayer else { return }
		mediaStateDidChange()

		guard let duration = duration, duration > 0 else { return }
		print("[\(String(describing: contentSource))] mediaPlayerTimeChanged \(player.time.verboseStringValue)/\(player.remainingTime.verboseStringValue)")
	}
	
	func mediaPlayerStateChanged(_ aNotification: Notification!) {
		guard let player = mediaPlayer else { return }
//		print("[\(String(describing: contentSource))] mediaPlayerStateChanged \(player.state.debugDescription)")
		mediaStateDidChange()
	}
	
	func mediaPlayerTitleChanged(_ aNotification: Notification!) {
		print("[\(String(describing: contentSource))] mediaPlayerTitleChanged")
	}
	
	func mediaPlayerChapterChanged(_ aNotification: Notification!) {
		print("[\(String(describing: contentSource))] mediaPlayerChapterChanged")
	}
	
	func mediaPlayerLoudnessChanged(_ aNotification: Notification!) {
		//print("mediaPlayerLoudnessChanged")
	}
	
	func mediaPlayerStartedRecording(_ player: VLCMediaPlayer!) {
		print("[\(String(describing: contentSource))] mediaPlayerStartedRecording")
	}
	
	func mediaPlayer(_ player: VLCMediaPlayer!, recordingStoppedAtPath path: String!) {
		print("[\(String(describing: contentSource))] mediaPlayer recordingStoppedAtPath")
	}
}


func lock(on obj: AnyObject, blk: () -> Void) {
	objc_sync_enter(obj)
	blk()
	objc_sync_exit(obj)
}

func lock<T>(on obj: AnyObject, blk: () throws -> T) rethrows -> T {
	objc_sync_enter(obj)
	let value = try blk()
	objc_sync_exit(obj)
	return value
}


class MediaPlayerFactory {
	
	static let shared = MediaPlayerFactory()
	
	private var avaliablePlayers: [VLCMediaPlayer] = []
	private var loanedPlayers: [VLCMediaPlayer] = []
	
	private var disposeTask: DispatchWorkItem?
	
	private func createLibrary() -> VLCLibrary {
		// Custom properties required for faster RTSP playback
//		var options = [Any]()
//		options.append("--rtsp-tcp")
//		let library = VLCLibrary(options: options)
//		return library
		
		return VLCLibrary.shared()
	}
	
	func get() -> VLCMediaPlayer {
		return lock(on: self) { () -> VLCMediaPlayer in
			guard avaliablePlayers.isEmpty else {
				print(">> Re-use avaliable player")
				let player = avaliablePlayers.removeFirst()
				loanedPlayers.append(player)
				return player
			}
	 		print(">> Create new player")
			let player = VLCMediaPlayer(library: createLibrary())!
			loanedPlayers.append(player)
			return player
		}
	}
	
	func put(_ player: VLCMediaPlayer) {
		lock(on: self) {
			disposeTask?.cancel()
			player.delegate = nil
			player.stopRecording()
			player.stop()
			player.drawable = nil
			// This could be problematic
			player.media = nil
			
			loanedPlayers.removeAll { player == $0 }
			avaliablePlayers.append(player)
			
			let task = DispatchWorkItem {
				self.clearCache()
			}
			disposeTask = task
			DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
		}
	}
	
	fileprivate func clearCache() {
		lock(on: self) {
			print(">> Remove \(avaliablePlayers.count)")
			guard !avaliablePlayers.isEmpty else { return }
			avaliablePlayers.removeAll()
		}
	}
	
}
