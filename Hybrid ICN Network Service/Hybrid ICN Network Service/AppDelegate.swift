import Cocoa
import Preferences

extension PreferencePane.Identifier {
	static let forwarder = Identifier("forwarder")
	static let hiperf = Identifier("hiperf")
}

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	var preferencesStyle: PreferencesStyle {
		get { PreferencesStyle.preferencesStyleFromUserDefaults() }
		set {
			newValue.storeInUserDefaults()
		}
	}

	lazy var forwarderViewController = ForwarderViewController()
	lazy var hiperfViewController = HiperfViewController()

	lazy var hicnPanelsWindowController = PreferencesWindowController(
		preferencePanes: [
			forwarderViewController,
			hiperfViewController
		],
		style: preferencesStyle,
		animated: true,
		hidesToolbarForSingleItem: true
	)

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.orderOut(self)
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		hicnPanelsWindowController.show(preferencePane: .forwarder)
		
	}
	
	@IBAction func showForwarder(_ sender: Any) {
		hicnPanelsWindowController.show(preferencePane: .forwarder)
	}
	
	@IBAction func showHIperf(_ sender: Any) {
		hicnPanelsWindowController.show(preferencePane: .hiperf)
	}
	
	
	//func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		//forwarderViewController.test()
		
		//return false
	//}
	
}
