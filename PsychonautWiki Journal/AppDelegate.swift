import UIKit
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerHandler()
        return true
    }

    let taskIdentifier = "com.isaak.substance-refresh"

    private func registerHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            // swiftlint:disable force_cast
            self.handleSubstancesRefresh(task: task as! BGProcessingTask)
        }
    }

    private func handleSubstancesRefresh(task: BGProcessingTask) {
        scheduleSubstancesRefresh()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            refreshSubstances {
                task.setTaskCompleted(success: true)
            }
        }
    }

    // This function must be called from the onChange(scenePhase:) modifier because
    // applicationDidEnterBackground(_ application: UIApplication) is not called in this class
    func scheduleSubstancesRefresh() {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        // Apple recommends to keep earliestBeginDate under a week else it might not be scheduled at all
        let twoDays: TimeInterval = 2*24*60*60
        request.earliestBeginDate = Date(timeIntervalSinceNow: twoDays)
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule substances refresh: \(error)")
        }
    }

}
