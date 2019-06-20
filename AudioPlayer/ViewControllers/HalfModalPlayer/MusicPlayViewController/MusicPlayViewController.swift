//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/01/28.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class MusicPlayViewController: UIViewController {
    
    var tableView: UITableView = UITableView()
    
    let headerHeight: CGFloat = 50
    let artworkCellHeight: CGFloat = 500
    let controllerCellHeight: CGFloat = 250
    let queueCellHeight: CGFloat = 60
    
    private let mediaPlayerOutPut: MediaPlayerOutputQueueProtocol = AudioPlayer.shared
    private let queueController: MediaPlayerInputQueueProtocol = AudioPlayer.shared
    private let dataSource: UITableViewDataSource = MusicPlayViewControllerDataSource()
    
    deinit {
        DebugUtil.log("MusicPlayer is deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            let safeAreaConstrints = self.view.safeAreaLayoutGuide.snp
            maker.top.equalTo(safeAreaConstrints.top)
            maker.leading.equalTo(safeAreaConstrints.leading)
            maker.bottom.equalTo(safeAreaConstrints.bottom)
            maker.trailing.equalTo(safeAreaConstrints.trailing)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "AudioControllerCell", bundle: nil), forCellReuseIdentifier: "ControlCell")
        self.tableView.register(UINib(nibName: "AudioArtworkCell", bundle: nil), forCellReuseIdentifier: "ArtworkCell")
        self.tableView.register(UINib(nibName: "AudioQueueCell", bundle: nil), forCellReuseIdentifier: "QueueCell")
        self.tableView.register(UINib(nibName: "AudioQueueSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "QueueHeader")
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(selectItem), name: UIApplication.willEnterForegroundNotification, object: nil)
        MPMusicPlayerApplicationController.applicationQueuePlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(selectItem), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        MPMusicPlayerApplicationController.applicationQueuePlayer.endGeneratingPlaybackNotifications()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectItem()
    }
}
extension MusicPlayViewController: UITableViewDelegate {
    @objc func selectItem() {
        let index = self.mediaPlayerOutPut.indexOfNowPlayingItem ?? 0
        self.tableView.selectRow(at: IndexPath(item: index, section: 1), animated: true, scrollPosition: .none)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return self.headerHeight
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.item == 0 {
                return self.artworkCellHeight
            } else {
                return self.controllerCellHeight
            }
        default:
            return self.queueCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        default:
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "QueueHeader") as? AudioQueueSectionHeader else {
                return nil
            }
            return header
        }
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.queueController.updateQueue(index: indexPath.item, isPlay: true)
        default:
            return
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch indexPath.section {
        case 0:
            return nil
        default:
            return indexPath
        }
    }
    func tableView(_ tableView:UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.section != sourceIndexPath.section) {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        updateViewPosition(contentoffsetY: y)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let y = scrollView.contentOffset.y
        checkDismissingCondition(withScrollOffset: y)
    }
}
extension MusicPlayViewController {
    func updateViewPosition(contentoffsetY y: CGFloat ) {
        let move = min(y, 0)
        self.view.frame.origin.y = -move
        self.tableView.subviews.map { $0.transform = CGAffineTransform(translationX: 0, y: move)}
    }
    private func checkDismissingCondition(withScrollOffset y: CGFloat) {
        // 移動量が一定値を超えたらモーダルビューを閉じる（全体の1/6くらい）
        if y < -self.view.frame.height / 6 {
            // モーダルビューを閉じた後に一瞬スクロールビューの中身がバウンスで戻る映像が見えてしまう対策
            self.tableView.isScrollEnabled = false
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false) // 慣性スクロールを強制停止
            self.tableView.contentOffset = CGPoint(x: 0, y: y)
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.view.frame.height), animated: true)
            self.dismiss(animated: false, completion: nil)
        }
    }
}
