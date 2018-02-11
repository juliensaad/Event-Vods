//
//  EventTableViewCell.swift
//  Event Vods
//
//  Created by Julien Saad on 2018-02-11.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Cards
import Siesta

protocol EventTableViewCellDelegate: NSObjectProtocol {
    func didSelectCell(cell: EventTableViewCell)
}

class EventTableViewCell: UITableViewCell {
    
    weak var delegate: EventTableViewCellDelegate?
    
    static let reuseIdentifier = "EventTableViewCell"
    
    private let card = CardHighlight()
    
    var imageURL: URL? {
        get { return imageResource?.url }
        set { imageResource = ImageCache.resource(absoluteURL: newValue) }
    }
    
    var placeholderImage: UIImage {
        return UIImage()
    }
    
    var imageResource: Resource? {
        willSet {
            imageResource?.removeObservers(ownedBy: self)
            imageResource?.cancelLoadIfUnobserved(afterDelay: 0.05)
        }
        
        didSet {
            imageResource?.loadIfNeeded()
            imageResource?.addObserver(owner: self) { [weak self] _,_ in
                self?.card.icon = self?.imageResource?.typedContent(
                    ifNone: self?.placeholderImage)
            }
        }
    }
    
    init(event: Event, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        card.icon = UIImage(named: "flappy")
        card.title = event.name
        card.itemTitle = event.slug
        card.itemSubtitle = event.startDate?.description ?? ""
        card.textColor = UIColor.white
        
        card.hasParallax = true
        card.delegate = self
        
        
        contentView.addSubview(card)
        
        card.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if let logo = event.logo {
            imageURL = URL(string: logo)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("IB not supported")
    }
    
    
}

extension EventTableViewCell: CardDelegate {
    func cardDidTapInside(card: Card) {
        self.delegate?.didSelectCell(cell: self)
    }
}
