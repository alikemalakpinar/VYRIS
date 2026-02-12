import SwiftUI
import AVFoundation
import Contacts
import ContactsUI

// MARK: - QR Scanner View
// Scans QR codes, parses vCard data, and presents iOS contact add sheet.
// Requires explicit user tap to save (privacy compliant).

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedVCard: String?
    @State private var showContactSheet = false
    @State private var cameraPermissionDenied = false

    var body: some View {
        NavigationStack {
            ZStack {
                VYRISColors.Semantic.backgroundPrimary.ignoresSafeArea()

                if cameraPermissionDenied {
                    cameraPermissionView
                } else {
                    VStack(spacing: VYRISSpacing.lg) {
                        Text("scanner.instruction")
                            .font(VYRISTypography.body())
                            .foregroundColor(VYRISColors.Semantic.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, VYRISSpacing.lg)

                        QRCameraPreview(onCodeScanned: handleScannedCode)
                            .clipShape(RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: VYRISCardDimensions.cornerRadius)
                                    .strokeBorder(VYRISColors.Semantic.stroke, lineWidth: 0.5)
                            )
                            .padding(.horizontal, VYRISSpacing.lg)

                        if scannedVCard != nil {
                            Button {
                                showContactSheet = true
                            } label: {
                                Text("scanner.addContact")
                                    .font(VYRISTypography.button())
                                    .foregroundColor(.white)
                                    .tracking(1)
                                    .padding(.vertical, VYRISSpacing.sm)
                                    .padding(.horizontal, VYRISSpacing.xl)
                                    .background(VYRISColors.Semantic.accent)
                                    .clipShape(Capsule())
                            }
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle(Text("scanner.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Text("common.cancel").font(VYRISTypography.body())
                    }
                }
            }
            .sheet(isPresented: $showContactSheet) {
                if let vCard = scannedVCard {
                    ContactAddSheet(vCardString: vCard)
                }
            }
            .onAppear(perform: checkCameraPermission)
        }
    }

    private var cameraPermissionView: some View {
        VStack(spacing: VYRISSpacing.md) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(VYRISColors.Semantic.textSecondary)
            Text("scanner.cameraPermission")
                .font(VYRISTypography.body())
                .foregroundColor(VYRISColors.Semantic.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(VYRISSpacing.xl)
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionDenied = !granted
                }
            }
        default:
            cameraPermissionDenied = true
        }
    }

    private func handleScannedCode(_ code: String) {
        guard code.contains("BEGIN:VCARD") else { return }
        VYRISHaptics.medium()
        scannedVCard = code
    }
}

// MARK: - Camera Preview (AVFoundation)

struct QRCameraPreview: UIViewRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        let onCodeScanned: (String) -> Void
        private var hasScanned = false

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !hasScanned,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = object.stringValue else { return }
            hasScanned = true
            onCodeScanned(value)
        }
    }
}

// MARK: - Contact Add Sheet (CNContactViewController wrapper)
// Pre-fills contact from vCard, requires explicit user tap to save.

struct ContactAddSheet: UIViewControllerRepresentable {
    let vCardString: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UINavigationController {
        let contact = parseVCard(vCardString)
        let vc = CNContactViewController(forNewContact: contact)
        vc.delegate = context.coordinator
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func contactViewController(
            _ viewController: CNContactViewController,
            didCompleteWith contact: CNContact?
        ) {
            dismiss()
        }
    }

    /// Parse a vCard string into a CNMutableContact.
    private func parseVCard(_ vCard: String) -> CNMutableContact {
        let contact = CNMutableContact()

        let lines = vCard.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.split(separator: ":", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0].uppercased()
            let value = parts[1]
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "\\;", with: ";")
                .replacingOccurrences(of: "\\,", with: ",")
                .replacingOccurrences(of: "\\\\", with: "\\")

            if key == "FN" {
                let nameParts = value.split(separator: " ", maxSplits: 1)
                contact.givenName = String(nameParts.first ?? "")
                if nameParts.count > 1 {
                    contact.familyName = String(nameParts[1])
                }
            } else if key == "ORG" {
                contact.organizationName = value
            } else if key == "TITLE" {
                contact.jobTitle = value
            } else if key.hasPrefix("TEL") {
                contact.phoneNumbers.append(
                    CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: value))
                )
            } else if key.hasPrefix("EMAIL") {
                contact.emailAddresses.append(
                    CNLabeledValue(label: CNLabelWork, value: value as NSString)
                )
            } else if key == "URL" {
                contact.urlAddresses.append(
                    CNLabeledValue(label: CNLabelURLAddressHomePage, value: value as NSString)
                )
            }
        }

        return contact
    }
}
