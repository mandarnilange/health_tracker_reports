import Flutter
import UIKit
import PDFKit
import Vision
import ImageIO

private let reportScanMethodChannel = "report_scan/methods"
private let reportScanEventChannel = "report_scan/events"

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let reportScanHandler = ReportScanStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(
        name: reportScanMethodChannel,
        binaryMessenger: controller.binaryMessenger
      )

      let eventChannel = FlutterEventChannel(
        name: reportScanEventChannel,
        binaryMessenger: controller.binaryMessenger
      )

      eventChannel.setStreamHandler(reportScanHandler)

      methodChannel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(
            FlutterError(
              code: "no_app_delegate",
              message: "AppDelegate deallocated",
              details: nil
            )
          )
          return
        }

        switch call.method {
        case "startScan":
          reportScanHandler.start(arguments: call.arguments)
          result(nil)
        case "cancelScan":
          reportScanHandler.cancel()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private enum ScanSource: String {
  case pdf
  case images
}

private struct ReportScanRequest {
  let source: ScanSource
  let uri: String
  let imageUris: [String]

  init?(arguments: Any?) {
    guard
      let map = arguments as? [String: Any],
      let sourceString = map["source"] as? String,
      let source = ScanSource(rawValue: sourceString),
      let uri = map["uri"] as? String
    else {
      return nil
    }

    self.source = source
    self.uri = uri
    if let images = map["imageUris"] as? [String] {
      imageUris = images
    } else {
      imageUris = []
    }
  }

  func fileURL() -> URL? {
    if let url = URL(string: uri), url.isFileURL {
      return url
    }
    return URL(fileURLWithPath: (uri as NSString).expandingTildeInPath)
  }

  func imageFileURLs() -> [URL] {
    let targets = imageUris.isEmpty ? [uri] : imageUris
    return targets.compactMap { value in
      if let url = URL(string: value), url.isFileURL {
        return url
      }
      return URL(fileURLWithPath: (value as NSString).expandingTildeInPath)
    }
  }
}

private class ReportScanStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var pendingArguments: Any?
  private var currentWorkItem: DispatchWorkItem?
  private let processingQueue = DispatchQueue(label: "report_scan_queue", qos: .userInitiated)

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    if let args = pendingArguments {
      pendingArguments = nil
      start(arguments: args)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    cancel()
    eventSink = nil
    pendingArguments = nil
    return nil
  }

  func start(arguments: Any?) {
    guard let sink = eventSink else {
      pendingArguments = arguments
      return
    }

    guard let request = ReportScanRequest(arguments: arguments) else {
      sendError(code: "invalid_request", message: "Invalid scan arguments")
      return
    }

    currentWorkItem?.cancel()
    let workItem = DispatchWorkItem { [weak self] in
      self?.performScan(request: request)
    }
    currentWorkItem = workItem

    // Emit initial progress to indicate work started.
    DispatchQueue.main.async {
      if request.source == .pdf {
        sink(["type": "progress", "page": 0, "totalPages": 0])
      } else {
        sink(["type": "progress", "page": 0, "totalPages": request.imageUris.count])
      }
    }

    processingQueue.async(execute: workItem)
  }

  func cancel() {
    currentWorkItem?.cancel()
    currentWorkItem = nil
  }

  private func performScan(request: ReportScanRequest) {
    guard let currentWorkItem else { return }

    do {
      switch request.source {
      case .pdf:
        try processPdf(request: request, workItem: currentWorkItem)
      case .images:
        try processImages(request: request, workItem: currentWorkItem)
      }

      if !currentWorkItem.isCancelled {
        emit(["type": "complete"])
      }
    } catch {
      if !currentWorkItem.isCancelled {
        sendError(code: "scan_failed", message: error.localizedDescription)
      }
    }
  }

  private func processPdf(request: ReportScanRequest, workItem: DispatchWorkItem) throws {
    guard let fileURL = request.fileURL() else {
      throw NSError(domain: "report_scan", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF path"])
    }

    guard let document = PDFDocument(url: fileURL) else {
      throw NSError(domain: "report_scan", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to open PDF"])
    }

    let pageCount = document.pageCount
    for index in 0..<pageCount {
      if workItem.isCancelled { return }

      emit(["type": "progress", "page": index + 1, "totalPages": pageCount])

      guard let page = document.page(at: index) else { continue }
      let pageText = page.string ?? ""
      let structured = buildStructuredPayload(from: pageText)

      emit([
        "type": "structured",
        "page": index + 1,
        "totalPages": pageCount,
        "payload": structured,
      ])
    }
  }

  private func processImages(request: ReportScanRequest, workItem: DispatchWorkItem) throws {
    let imageURLs = request.imageFileURLs()
    if imageURLs.isEmpty {
      throw NSError(domain: "report_scan", code: -3, userInfo: [NSLocalizedDescriptionKey: "No images supplied"])
    }

    for (index, url) in imageURLs.enumerated() {
      if workItem.isCancelled { return }

      guard let image = UIImage(contentsOfFile: url.path) else {
        continue
      }

      guard let cgImage = image.cgImage else {
        continue
      }

      let text = try recognizeText(in: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))

      if workItem.isCancelled { return }

      emit(["type": "progress", "page": index + 1, "totalPages": imageURLs.count])

      let structured = buildStructuredPayload(from: text)
      emit([
        "type": "structured",
        "page": index + 1,
        "totalPages": imageURLs.count,
        "payload": structured,
      ])
    }
  }

  private func recognizeText(in image: CGImage, orientation: CGImagePropertyOrientation) throws -> String {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false

    let handler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
    try handler.perform([request])

    guard let observations = request.results as? [VNRecognizedTextObservation] else { return "" }

    let lines = observations.compactMap { observation -> String? in
      observation.topCandidates(1).first?.string
    }

    return lines.joined(separator: "\n")
  }

  private func buildStructuredPayload(from text: String) -> [String: Any] {
    let biomarkers = parseBiomarkers(from: text)
    return [
      "rawText": text,
      "biomarkers": biomarkers,
    ]
  }

  private func parseBiomarkers(from text: String) -> [[String: Any]] {
    var results: [[String: Any]] = []
    let lines = text.components(separatedBy: .newlines)

    guard let valueRegex = try? NSRegularExpression(
      pattern: #"^\s*([A-Za-z][A-Za-z0-9 .%/µ×^()+'\-]+?)(?:\s*[:\-]\s*)?([+\-]?\d+(?:[.,]\d+)?)(.*)$"#,
      options: [.caseInsensitive]
    ) else { return results }

    let rangeRegex = try? NSRegularExpression(
      pattern: #"([+\-]?\d+(?:[.,]\d+)?)\s*[-–]\s*([+\-]?\d+(?:[.,]\d+)?)"#,
      options: []
    )

    let metadataKeywords = [
      "patient",
      "bill",
      "collected",
      "report",
      "release",
      "specimen",
      "registration",
      "lab",
      "ref",
      "uhid",
      "doctor",
      "hospital",
      "age",
      "gender",
      "date",
      "method",
      "processing",
      "session"
    ]

    for rawLine in lines {
      let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
      guard trimmed.count > 2 else { continue }

      let nsLine = trimmed as NSString
      let range = NSRange(location: 0, length: nsLine.length)

      guard let match = valueRegex.firstMatch(in: trimmed, options: [], range: range) else {
        continue
      }

      let name = nsLine
        .substring(with: match.range(at: 1))
        .trimmingCharacters(in: .whitespacesAndNewlines)

      guard !name.isEmpty else { continue }
      let lowerName = name.lowercased()
      if metadataKeywords.contains(where: { lowerName.contains($0) }) {
        continue
      }

      let valueString = nsLine
        .substring(with: match.range(at: 2))
        .trimmingCharacters(in: .whitespacesAndNewlines)

      let numericValue = valueString
        .replacingOccurrences(of: ",", with: ".")
      guard Double(numericValue) != nil else { continue }

      var remainder = ""
      if match.numberOfRanges > 3, match.range(at: 3).location != NSNotFound {
        remainder = nsLine
          .substring(with: match.range(at: 3))
          .trimmingCharacters(in: .whitespacesAndNewlines)
      }

      var referenceMin: String?
      var referenceMax: String?
      var unitCandidate = remainder

      if let rangeRegex,
         let rangeMatch = rangeRegex.firstMatch(
           in: remainder,
           options: [],
           range: NSRange(location: 0, length: (remainder as NSString).length)
         ) {
        referenceMin = (remainder as NSString).substring(with: rangeMatch.range(at: 1))
        referenceMax = (remainder as NSString).substring(with: rangeMatch.range(at: 2))

        let prefix = (remainder as NSString).substring(to: rangeMatch.range.location)
        let suffix = (remainder as NSString).substring(from: rangeMatch.range.location + rangeMatch.range.length)
        unitCandidate = (prefix + " " + suffix).trimmingCharacters(in: .whitespacesAndNewlines)
      }

      let sanitizedUnit = unitCandidate
        .trimmingCharacters(in: CharacterSet(charactersIn: " -"))

      let hasMeasurementCharacters: Bool = {
        let measurementChars = CharacterSet(charactersIn: "%/µxX^flpgmdLcells")
        if sanitizedUnit.rangeOfCharacter(from: measurementChars) != nil {
          return true
        }
        if sanitizedUnit.rangeOfCharacter(from: .letters) != nil {
          return true
        }
        return false
      }()

      if sanitizedUnit.isEmpty && referenceMin == nil {
        continue
      }

      if referenceMin == nil && !hasMeasurementCharacters {
        continue
      }

      var biomarker: [String: Any] = [
        "name": name,
        "value": valueString,
      ]

      if !sanitizedUnit.isEmpty {
        biomarker["unit"] = sanitizedUnit
      }
      if let referenceMin {
        biomarker["referenceMin"] = referenceMin
      }
      if let referenceMax {
        biomarker["referenceMax"] = referenceMax
      }

      results.append(biomarker)
    }

    return results
  }

  private func emit(_ data: [String: Any]) {
    guard let eventSink else { return }
    DispatchQueue.main.async {
      eventSink(data)
    }
  }

  private func sendError(code: String, message: String) {
    emit([
      "type": "error",
      "code": code,
      "message": message,
    ])
  }
}

extension CGImagePropertyOrientation {
  init(_ orientation: UIImage.Orientation) {
    switch orientation {
    case .up: self = .up
    case .down: self = .down
    case .left: self = .left
    case .right: self = .right
    case .upMirrored: self = .upMirrored
    case .downMirrored: self = .downMirrored
    case .leftMirrored: self = .leftMirrored
    case .rightMirrored: self = .rightMirrored
    @unknown default: self = .up
    }
  }
}
