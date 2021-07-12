//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation

public extension _ChatClient {
    func createEventsController() -> EventsController {
        .init(notificationCenter: eventNotificationCenter)
    }
}

public class EventsController: Controller {
    public var callbackQueue: DispatchQueue = .main
    private let notificationCenter: EventNotificationCenter
    private var observers: [EventObserver] = []
    
    init(notificationCenter: EventNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    // MARK: - System events
    
    public func subscribe<T: Event>(
        on: T.Type = T.self,
        filter: @escaping (T) -> Bool = { _ in true },
        handler: @escaping (T) -> Void
    ) {
        observers += [
            .init(
                notificationCenter: notificationCenter,
                transform: { $0 as? T },
                callback: { [unowned self] event in
                    guard filter(event) else { return }
                    self.callback { handler(event) }
                }
            )
        ]
    }
    
    // MARK: - Custom events
    
    public func subscribe<T: CustomEvent>(
        on: T.Type = T.self,
        filter: @escaping (T) -> Bool = { _ in true },
        handler: @escaping (T) -> Void
    ) {
        subscribe(on: AnyCustomEvent.self) {
            guard let event = $0.event(ofType: T.self), filter(event) else { return }
            handler(event)
        }
    }
    
    public func send<T: CustomEvent>(
        event: T.Type = T.self,
        completion: @escaping (Error?) -> Void
    ) {
        // TODO:
    }
    
    // MARK: - Cancel observation
    
    public func removeAllObservers() {
        observers.removeAll()
    }
}

// MARK: - Message events

public extension EventsController {
    func subscribeOnMessageNewEvent(
        for messageId: MessageId,
        handler: @escaping (MessageNewEvent) -> Void
    ) {
        subscribe(
            filter: { $0.messageId == messageId },
            handler: handler
        )
    }
    
    func subscribeOnMessageUpdatedEvent(
        for messageId: MessageId,
        handler: @escaping (MessageUpdatedEvent) -> Void
    ) {
        subscribe(
            filter: { $0.messageId == messageId },
            handler: handler
        )
    }
    
    func subscribeOnMessageDeletedEvent(
        for messageId: MessageId,
        handler: @escaping (MessageDeletedEvent) -> Void
    ) {
        subscribe(
            filter: { $0.messageId == messageId },
            handler: handler
        )
    }
}

// MARK: - Channel events

public extension EventsController {
    func subscribeOnChannelUpdatedEvent(
        for cid: ChannelId,
        handler: @escaping (ChannelUpdatedEvent) -> Void
    ) {
        subscribe(
            filter: { $0.cid == cid },
            handler: handler
        )
    }
    
    func subscribeOnChannelDeletedEvent(
        for cid: ChannelId,
        handler: @escaping (ChannelDeletedEvent) -> Void
    ) {
        subscribe(
            filter: { $0.cid == cid },
            handler: handler
        )
    }
    
    func subscribeOnChannelTruncatedEvent(
        for cid: ChannelId,
        handler: @escaping (ChannelTruncatedEvent) -> Void
    ) {
        subscribe(
            filter: { $0.cid == cid },
            handler: handler
        )
    }
    
    func subscribeOnChannelVisibleEvent(
        for cid: ChannelId,
        handler: @escaping (ChannelVisibleEvent) -> Void
    ) {
        subscribe(
            filter: { $0.cid == cid },
            handler: handler
        )
    }
    
    func subscribeOnChannelHiddenEvent(
        for cid: ChannelId,
        handler: @escaping (ChannelHiddenEvent) -> Void
    ) {
        subscribe(
            filter: { $0.cid == cid },
            handler: handler
        )
    }
}
