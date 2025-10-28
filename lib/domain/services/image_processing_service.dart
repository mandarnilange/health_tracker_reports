/// Service for processing PDFs and images for LLM extraction
abstract class ImageProcessingService {
  /// Converts PDF file to list of base64-encoded PNG images
  Future<List<String>> pdfToBase64Images(String pdfPath);

  /// Converts image file to base64-encoded string
  Future<String> imageToBase64(String imagePath);

  /// Compresses base64 image to reduce size for API calls
  Future<String> compressImageBase64(String base64Image);
}
