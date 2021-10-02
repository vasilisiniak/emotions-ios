import Foundation
import StoreKit
import Utils

public protocol PromoManager {
    func trackAppLaunch()
    func trackActivityEnded(sender: PromoManagerSender)
}

public protocol PromoManagerSender {
    func presentRate()
    func presentShare()
}

public final class PromoManagerImpl {

    private enum Constants {
        fileprivate static let LaunchesKey = "Model.PromoManagerImpl.LaunchesKey"
        fileprivate static let VersionKey = "Model.PromoManagerImpl.VersionKey"
        fileprivate static let LaunchDateKey = "Model.PromoManagerImpl.LaunchDateKey"
        fileprivate static let FirstRateKey = "Model.PromoManagerImpl.FirstRateKey"
        fileprivate static let FirstShareKey = "Model.PromoManagerImpl.FirstShareKey"
    }

    // MARK: - Private

    private var launchesSinceLastAction: Int {
        get { UserDefaults.standard.integer(forKey: Constants.LaunchesKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.LaunchesKey); UserDefaults.standard.synchronize() }
    }

    private var lastRateAppVersion: String? {
        get { UserDefaults.standard.string(forKey: Constants.VersionKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.VersionKey); UserDefaults.standard.synchronize() }
    }

    private var lastLaunchDate: Date? {
        get { Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Constants.LaunchDateKey)) }
        set { UserDefaults.standard.setValue(newValue?.timeIntervalSince1970, forKey: Constants.LaunchDateKey); UserDefaults.standard.synchronize() }
    }

    private var shownRateAtLeastOnce: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.FirstRateKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.FirstRateKey); UserDefaults.standard.synchronize() }
    }

    private var shownShareAtLeastOnce: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.FirstShareKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.FirstShareKey); UserDefaults.standard.synchronize() }
    }

    private func initLaunches(emotionsProvider: EmotionEventsProvider) {
        launchesSinceLastAction = emotionsProvider.events
            .map(\.date.dateOnly)
            .reduce(into: Set()) { $0.insert($1) }
            .count
    }

    private func present(rate sender: PromoManagerSender) {
        sender.presentRate()
        shownRateAtLeastOnce = true
        launchesSinceLastAction = 1
        lastRateAppVersion = Bundle.main.appVersion
    }

    private func present(share sender: PromoManagerSender) {
        sender.presentShare()
        shownShareAtLeastOnce = true
        launchesSinceLastAction = 1
    }

    // MARK: - Public

    public init(emotionsProvider: EmotionEventsProvider) {
        if launchesSinceLastAction == 0 {
            initLaunches(emotionsProvider: emotionsProvider)
        }
    }
}

extension PromoManagerImpl: PromoManager {
    public func trackAppLaunch() {
        guard Date().dateOnly != lastLaunchDate else { return }
        launchesSinceLastAction = launchesSinceLastAction + 1
        lastLaunchDate = Date().dateOnly
    }

    public func trackActivityEnded(sender: PromoManagerSender) {
        if !shownRateAtLeastOnce {
            if launchesSinceLastAction > 20 {
                present(rate: sender)
            }
        }
        else if !shownShareAtLeastOnce {
            if launchesSinceLastAction > 10 {
                present(share: sender)
            }
        }
        else {
            if launchesSinceLastAction > 50 {
                if lastRateAppVersion != Bundle.main.appVersion {
                    present(rate: sender)
                }
                else {
                    present(share: sender)
                }
            }
        }
    }
}
