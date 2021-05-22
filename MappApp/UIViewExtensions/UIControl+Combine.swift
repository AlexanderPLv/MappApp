//
//  UIControl+Combine.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 20.04.2021.
//

import UIKit
import Combine

extension UIControl {
    func publisher(for event: Event) -> EventPublisher {
        EventPublisher(
            control: self,
            event: event
        )
    }
}

extension UIControl {
    struct EventPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Never

        fileprivate var control: UIControl
        fileprivate var event: Event

        func receive<S: Subscriber>(
            subscriber: S
        ) where S.Input == Output, S.Failure == Failure {
            let subscription = EventSubscription<S>()
            subscription.target = subscriber
            subscriber.receive(subscription: subscription)

            control.addTarget(subscription,
                action: #selector(subscription.trigger),
                for: event
            )
        }
    }
}

private extension UIControl {
    class EventSubscription<Target: Subscriber>: Subscription
        where Target.Input == Void {
        var target: Target?
        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            target = nil
        }

        @objc func trigger() {
            target?.receive(())
        }
    }
}
