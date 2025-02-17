//
//  IntentHandlers.swift
//  MullvadVPN
//
//  Created by pronebird on 26/05/2022.
//  Copyright © 2022 Mullvad VPN AB. All rights reserved.
//

import Foundation

final class StartVPNIntentHandler: NSObject, StartVPNIntentHandling {
    func handle(intent: StartVPNIntent, completion: @escaping (StartVPNIntentResponse) -> Void) {
        TunnelManager.shared.startTunnel { operationCompletion in
            let code: StartVPNIntentResponseCode = operationCompletion.isSuccess
                ? .success
                : .failure
            let response = StartVPNIntentResponse(code: code, userActivity: nil)

            completion(response)
        }
    }
}

final class StopVPNIntentHandler: NSObject, StopVPNIntentHandling {
    func handle(intent: StopVPNIntent, completion: @escaping (StopVPNIntentResponse) -> Void) {
        TunnelManager.shared.stopTunnel { operationCompletion in
            let code: StopVPNIntentResponseCode = operationCompletion.isSuccess
                ? .success
                : .failure
            let response = StopVPNIntentResponse(code: code, userActivity: nil)

            completion(response)
        }
    }
}

final class ReconnectVPNIntentHandler: NSObject, ReconnectVPNIntentHandling {
    func handle(
        intent: ReconnectVPNIntent,
        completion: @escaping (ReconnectVPNIntentResponse) -> Void
    ) {
        let tunnelManager = TunnelManager.shared

        tunnelManager.reconnectTunnel(selectNewRelay: true) { operationCompletion in
            let error = operationCompletion.error

            let shouldStartTunnel: Bool
            if case .tunnelDown = error as? SendTunnelProviderMessageError {
                shouldStartTunnel = true
            } else {
                shouldStartTunnel = error is UnsetTunnelError
            }

            if shouldStartTunnel {
                tunnelManager.startTunnel { operationCompletion in
                    completion(
                        ReconnectVPNIntentResponse(
                            code: operationCompletion.isSuccess ? .success : .failure,
                            userActivity: nil
                        )
                    )
                }
            } else {
                completion(
                    ReconnectVPNIntentResponse(
                        code: operationCompletion.isSuccess ? .success : .failure,
                        userActivity: nil
                    )
                )
            }
        }
    }
}
