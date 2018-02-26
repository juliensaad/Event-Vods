//
//  VideoPlayerOverlay.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-25.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import UIKit

class VideoPlayerOverlay: UIView {

    let match: Match
    private lazy var matchupView: TeamMatchupView = {
        return TeamMatchupView()
    }()
    
    private lazy var playButton: UIButton = {
        return UIButton()
    }()

    private lazy var pauseButton: UIButton = {
        return UIButton()
    }()

    init(match: Match) {
        self.match = match
        super.init(frame: CGRect.zero)

        if let team1Icon = match.team1?.icon {
            matchupView.firstTeamIcon = URL(string: team1Icon)
        }

        if let team2Icon = match.team2?.icon {
            matchupView.secondTeamIcon = URL(string: team2Icon)
        }
        
        addSubview(matchupView)

        matchupView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func fadeIn() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}
