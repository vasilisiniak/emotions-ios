import Foundation
import UIKit

public enum SettingsPresenterRowStyle {
    case disclosure
    case switcher
    case option
}

public protocol SettingsPresenterRow {
    var title: String { get }
    var style: SettingsPresenterRowStyle { get }
    var value: Any? { get }
}

public protocol SettingsPresenterSection {
    var title: String { get }
    var subtitle: String? { get }
    var rows: [SettingsPresenterRow] { get }
}

public protocol SettingsPresenterOutput: AnyObject {
    func show(sections: [SettingsPresenterSection], update: [IndexPath])
    func show(message: String, okButton: String, infoButton: String?, okHandler: (() -> ())?)
    func show(options: [(String, () -> ())], cancel: String)
}

public protocol SettingsPresenter {
    var title: String { get }
    func eventViewReady()
    func event(selectIndexPath: IndexPath)
    func event(switcher: Bool, indexPath: IndexPath)
}
