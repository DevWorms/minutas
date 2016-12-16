//
//  CalendarioCell.swift
//  Minutas
//
//  Created by sergio ivan lopez monzon on 12/12/16.
//  Copyright © 2016 Uriel Mestas Estrada. All rights reserved.
//
import UIKit

struct Section {
    var name: String!
    var items: [String]!
    var collapsed: Bool!
    
    init(name: String, items: [String], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}


class CalendarioCell: UITableViewCell,UITableViewDataSource,UITableViewDelegate {
    
    
    var sections = [Section]()
    var subMenuTable:UITableView?
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpTable()
    }
    
    func setUpTable()
    {
        subMenuTable = UITableView(frame: CGRectZero, style:UITableViewStyle.Plain)
        subMenuTable?.delegate = self
        subMenuTable?.dataSource = self
        sections = [
            Section(name: "Tareas", items: ["Tarea 1", "Tarea 2", "Tarea 3", "Tarea 4", "Tarea 5", "Tarea 6", "Tarea 7", "Tarea 8"]),
            Section(name: "Reuniones", items: ["Reunion 1", "Reunion 2", "Reunion 3", "Reunion 4"]),
            
        ]
        
        self.addSubview(subMenuTable!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subMenuTable?.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5, self.bounds.size.height-5)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    
    // Cell
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell? ?? UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return sections[indexPath.section].collapsed! ? 0 : 44.0
    }
    
    // Header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

