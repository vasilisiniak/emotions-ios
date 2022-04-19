import Foundation

public final class Token {

    deinit {
        onDeinit(id)
    }

    // MARK: - Private

    private let onDeinit: (UUID) -> ()

    // MARK: - Public

    public let id = UUID()

    public init(onDeinit: @escaping (UUID) -> ()) {
        self.onDeinit = onDeinit
    }
}
