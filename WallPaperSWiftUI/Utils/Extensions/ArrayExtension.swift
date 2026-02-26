import Foundation

extension Array {
    var isNotEmpty : Bool {
        !isEmpty
    }
}


extension Array where Element == Int {
    func toCommaSeparatedString() -> String {
        self.map { String($0) }.joined(separator: ",")
    }
}

