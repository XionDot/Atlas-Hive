import Foundation
import Security

class AuthorizationHelper {
    func executeWithPrivileges(command: String, arguments: [String] = []) -> (success: Bool, output: String) {
        // Use AppleScript to execute commands with sudo privileges
        let fullCommand: String
        if arguments.isEmpty {
            fullCommand = command
        } else {
            fullCommand = ([command] + arguments).joined(separator: " ")
        }

        // Escape quotes in the command
        let escapedCommand = fullCommand.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        do shell script "\(escapedCommand)" with administrator privileges
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let output = scriptObject.executeAndReturnError(&error)

            if let error = error {
                print("AppleScript error: \(error)")
                return (false, error.description)
            }

            return (true, output.stringValue ?? "")
        }

        return (false, "Failed to create script")
    }
}
