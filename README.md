# Swift-EventListener

# EXAMPLE
# TableView Data binding 

Just add a couple of "set" methods to bind data and delegate your TableView

        tableView.set(onHeightForRowAt: {
                tableView, indexPath in
                
                return 40
        })
        
        tableView.set(onCellAtIndexPath: {
            tableView, indexPath in

            return UITableViewCell()
        })
        
        tableView.set(onNumberOfSections: {
            tableView in            
            return 1
        })
        
        tableView.set(onNumberOfRowsInSection: {
            tableView, section in
            
            return modelsArray.count
        }
        )
        
        tableView.set(onDidSelectRowAt: { [weak self]
            tableView, indexPath in
            
            guard self != nil else {
                return
            }
        }
        )




