import Foundation

let orderedSet = NSOrderedSet(array: [ 42, 43, 44])
orderedSet.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
    print("\(idx)")
}

for i in 0...5 {
    print("something")
}
