import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiApi {

  /// Used for prototype only.
  final String _apiKey = dotenv.env["GEMINI_KEY"] ?? "";
  late final GenerativeModel _model;

  GeminiApi({String model = 'gemini-1.5-flash-latest'}) {
    _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _apiKey);
  }

  Future<GenerateContentResponse> ask(List<Content> content) async {
    return await _model.generateContent(content);
  }

  // Future<
}
