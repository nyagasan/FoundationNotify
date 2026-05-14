import Foundation

public extension FoundationNotify {
    /// A configurable facade that wires generation, scheduling, authorization, and validation dependencies.
    struct Client: Sendable {
        public var generator: any NotificationGenerating
        public var scheduler: any NotificationScheduling
        public var authorizer: any NotificationAuthorizing
        public var validator: NotificationValidator

        public init(
            generator: any NotificationGenerating = FoundationModelsNotificationGenerator(),
            scheduler: any NotificationScheduling = UserNotificationScheduler(),
            authorizer: any NotificationAuthorizing = UserNotificationAuthorizationClient(),
            validator: NotificationValidator = NotificationValidator()
        ) {
            self.generator = generator
            self.scheduler = scheduler
            self.authorizer = authorizer
            self.validator = validator
        }

        public func generate(
            context: String,
            tone: NotificationTone,
            intent: NotificationIntent,
            locale: Locale? = .current,
            constraints: NotificationConstraints = .default
        ) async throws -> NotificationDraft {
            let request = FoundationNotify.Request(
                context: context,
                tone: tone,
                intent: intent,
                locale: locale,
                constraints: constraints
            )
            return try await generate(request)
        }

        public func generate(_ request: FoundationNotify.Request) async throws -> NotificationDraft {
            do {
                let draft = try await generator.generateNotification(for: request)
                try validator.validate(draft, constraints: request.constraints)
                return draft
            } catch let error as FoundationNotify.Error {
                throw error
            } catch {
                throw FoundationNotify.Error.generationFailed(String(describing: error))
            }
        }

        @discardableResult
        public func schedule(_ draft: NotificationDraft, trigger: NotificationTrigger) async throws -> String {
            try await schedule(draft, trigger: trigger, constraints: .default)
        }

        @discardableResult
        public func schedule(
            _ draft: NotificationDraft,
            trigger: NotificationTrigger,
            constraints: NotificationConstraints
        ) async throws -> String {
            try validator.validate(draft, constraints: constraints)
            try validator.validate(trigger)
            return try await scheduler.schedule(draft, trigger: trigger)
        }

        @discardableResult
        public func schedule(_ draft: NotificationDraft, after interval: NotificationTimeInterval) async throws -> String {
            try await schedule(draft, trigger: .timeInterval(interval.timeInterval, repeats: false))
        }

        @discardableResult
        public func schedule(_ draft: NotificationDraft, at date: Date) async throws -> String {
            try await schedule(draft, trigger: .date(date))
        }

        @discardableResult
        public func schedule(_ draft: NotificationDraft, components: DateComponents, repeats: Bool = false) async throws -> String {
            try await schedule(draft, trigger: .calendar(components, repeats: repeats))
        }

        @discardableResult
        public func schedule(_ draft: NotificationDraft, repeating schedule: NotificationSchedule) async throws -> String {
            try await self.schedule(draft, trigger: schedule.trigger)
        }

        @discardableResult
        public func schedule(
            after interval: NotificationTimeInterval,
            context: String,
            tone: NotificationTone,
            intent: NotificationIntent,
            locale: Locale? = .current,
            constraints: NotificationConstraints = .default
        ) async throws -> String {
            let draft = try await generate(
                context: context,
                tone: tone,
                intent: intent,
                locale: locale,
                constraints: constraints
            )
            return try await schedule(draft, trigger: .timeInterval(interval.timeInterval, repeats: false), constraints: constraints)
        }

        @discardableResult
        public func schedule(
            at date: Date,
            context: String,
            tone: NotificationTone,
            intent: NotificationIntent,
            locale: Locale? = .current,
            constraints: NotificationConstraints = .default
        ) async throws -> String {
            let draft = try await generate(
                context: context,
                tone: tone,
                intent: intent,
                locale: locale,
                constraints: constraints
            )
            return try await schedule(draft, trigger: .date(date), constraints: constraints)
        }

        @discardableResult
        public func schedule(
            repeating schedule: NotificationSchedule,
            context: String,
            tone: NotificationTone,
            intent: NotificationIntent,
            locale: Locale? = .current,
            constraints: NotificationConstraints = .default
        ) async throws -> String {
            let draft = try await generate(
                context: context,
                tone: tone,
                intent: intent,
                locale: locale,
                constraints: constraints
            )
            return try await self.schedule(draft, trigger: schedule.trigger, constraints: constraints)
        }

        public func requestAuthorization(options: NotificationAuthorizationOptions = .default) async throws -> Bool {
            try await authorizer.requestAuthorization(options: options)
        }

        public func authorizationStatus() async -> NotificationAuthorizationStatus {
            await authorizer.authorizationStatus()
        }
    }
}
