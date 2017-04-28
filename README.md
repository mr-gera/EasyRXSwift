# EasyRXSwift

# EXAMPLE  - TableView Data binding 

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


# EXAMPLE  - Event dispatching and subscribing

        class MyClass: NSObject {
            static let onEvent = "onEvent"

            func testDispatchNoData() {
                //Dispatch event
                dispatchEvent(with: MyClass.onEvent)
            }

            func testDispatchWithData() {

                //Dispatch event with custom data

                let event = Event(name: MyClass.onEvent)
                event.data = "I'm String Data!"
                dispatchEvent(event)
            }

            func testDispatchResult() {
                if let intValue = dispatchEvent(with: MyClass.onEvent) {
                    print("I'm Int Value! \(intValue)")
                }
            }

        }

        //////
        let object = MyClass()

        //Just add event listener for any class
        object.addEventListener(eventName: MyClass.onEvent, listeningObject: self) {
            event in

            if let data = event.data {
                print(data)
            } else {
                print("hello, data is nil!")
            }

            return 10000000
        }

        // do smth with your class

        object.testDispatchNoData()
        object.testDispatchWithData()
        object.testDispatchResult()

/////////////////////////////////////////////////////////////
// THE OUTPUT IS 
hello, data is nil!
I'm String Data!
hello, data is nil!
I'm Int Value! 10000000

    
