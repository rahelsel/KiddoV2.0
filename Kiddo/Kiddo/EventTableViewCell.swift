//
//  EventTableViewNib.swift
//  Kiddo
//
//  Created by Rachael A Helsel on 11/7/16.
//  Copyright © 2016 Filiz Kurban. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventVenueName: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!

    private let cache = SimpleCache.shared

    var event: Event? {
        didSet {
            updateUI()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.eventImage?.image = UIImage(named: "image_placeholder")
        self.eventTitle?.text = nil
        self.eventVenueName?.text = nil
        self.eventStartTime?.text = nil
    }

    private func updateUI() {
        //load new information from our event (if any)

        //cell view loads and shows white background for a short period of time. This looks very ugly. Turns out white background shows during the time we're waiting for the image download. Adding image placeholder to show here.
        //It'd be great if we could start the image download earlier.
        self.eventImage?.image = UIImage(named: "image_placeholder")

        if let event = event {
            self.eventTitle?.text = event.title
            self.eventVenueName?.text = event.location
            self.eventStartTime?.text = event.allDayFlag ? "ALL DAY" : DateUtil.shared.shortTime(from:event.startDate!)

            if let image = cache.image(key:event.imageURL!) {
                self.eventImage?.image = image
                return
            }

            //We don't have imageFile in the cache; let's retreive it from the server. Event photo is a PFFile in this state
            if let imageFile = event.photo {
                imageFile.getDataInBackground(block: { (imageData, error) in
                    guard error == nil else {
                        print ("Error retrieving image data from Parse")
                        return
                    }
                    guard let imageData = imageData else { return }
                    guard let image = UIImage(data: imageData) else { return }
                    
                    self.cache.setImage(image, key: event.imageURL!)
                    self.eventImage?.image = image
                })
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
