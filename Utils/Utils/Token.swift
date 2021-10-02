import Foundation

public final class Token {

    deinit {
        onDeinit(id)
    }

    // MARK: - Private

    private let onDeinit: (UUID) -> Void

    // MARK: - Public

    public let id = UUID()

    public init(onDeinit: @escaping (UUID) -> Void) {
        self.onDeinit = onDeinit
    }
}
