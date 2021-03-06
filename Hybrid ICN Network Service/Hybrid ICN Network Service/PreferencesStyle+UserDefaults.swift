import Foundation
import Preferences

// Helpers to write styles to and read them from UserDefaults.

extension PreferencesStyle: RawRepresentable {
	public var rawValue: Int {
		switch self {
		case .toolbarItems:
			return 0
		case .segmentedControl:
			return 1
		}
	}

	public init?(rawValue: Int) {
		switch rawValue {
		case 0:
			self = .toolbarItems
		case 1:
			self = .segmentedControl
		default:
			return nil
		}
	}
}

extension PreferencesStyle {
	static let userDefaultsKey = "preferencesStyle"

	static func preferencesStyleFromUserDefaults(_ userDefaults: UserDefaults = .standard) -> Self {
		.segmentedControl //Self(rawValue: userDefaults.integer(forKey: userDefaultsKey))
		//	?? .segmentedControl
	}

	func storeInUserDefaults(_ userDefaults: UserDefaults = .standard) {
		userDefaults.set(rawValue, forKey: Self.userDefaultsKey)
	}
}
