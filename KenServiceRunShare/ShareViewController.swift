import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    let appGroup = "group.com.kenneth.servicerun"
    override func viewDidLoad() {
        super.viewDidLoad()
        receiveSharedContent()
    }

private func receiveSharedContent() {
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = extensionItem.attachments
        else {
            finish()
            return
    }
    for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadItem(
                    forTypeIdentifier: UTType.url.identifier
                ) { [weak self] item, _ in
                    if let url = item as? URL {
                        self?.saveSharedContent(url.absoluteString)
                    } else {
                        self?.finish()
                    }
                }

                return
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadItem(
                    forTypeIdentifier: UTType.plainText.identifier
                ) { [weak self] item, _ in
                    if let text = item as? String {
                        self?.saveSharedContent(text)
                    } else {
                        self?.finish()
                    }
                }

                return
            }
        }

        finish()
    }
    private func saveSharedContent(_ content: String) {
        let defaults = UserDefaults(
            suiteName: appGroup
        )

        defaults?.set(
            content,
            forKey: "sharedContent"
        )

        defaults?.set(
            Date(),
            forKey: "sharedContentDate"
        )

        finish()
    }

    private func finish() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(
                returningItems: nil
            )
        }
    }
}
