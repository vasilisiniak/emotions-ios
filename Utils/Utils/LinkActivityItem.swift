import LinkPresentation

public final class LinkActivityItem: NSObject {

    // MARK: - Private

    private let metadata: LPLinkMetadata

    // MARK: - Pubic

    public init(title: String?, url: URL?, icon: UIImage?) {
        metadata = LPLinkMetadata()
        metadata.originalURL = url
        metadata.url = url
        metadata.title = title

        if let icon = icon {
            metadata.iconProvider = NSItemProvider(object: icon)
            metadata.imageProvider = NSItemProvider(object: icon)
        }
    }
}

extension LinkActivityItem: UIActivityItemSource {
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return metadata.originalURL ?? metadata.title ?? ""
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return metadata.originalURL
    }

    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return metadata
    }
}
