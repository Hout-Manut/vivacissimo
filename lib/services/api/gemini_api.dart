import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivacissimo/models/api_response.dart';
import 'package:vivacissimo/models/models.dart';
import 'package:vivacissimo/services/api/musicbrainz_api.dart';
import 'package:pool/pool.dart';
import 'package:vivacissimo/services/vivacissimo.dart';

class GeminiApi {
  late final String _apiKey;

  GeminiApi({String model = 'gemini-1.5-flash-latest'}) {
    _apiKey = dotenv.env["GEMINI_TOKEN"] ?? "";
  }

  Future<List<Release>> getReleases(String prompt) async {
    final GenerativeModel model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: ApiResponse.releaseListSchema),
    );

    printDebug(prompt);

    final GenerateContentResponse response = await model.generateContent(
      [Content.text(prompt)],
    );

    List<Release> releases = [];
    List<dynamic> results = jsonDecode(response.text!);

    final pool = Pool(5);

    printDebug(results);
    final List<Future<Release?>> futures = results
        .map((rawResult) => pool.withResource(() async {
              final Map<String, dynamic> result =
                  rawResult as Map<String, dynamic>;

              Release? release = await MusicbrainzApi.searchOneRelease(
                result["title"]!,
                result["artist"]!,
              );

              if (release != null) {
                Iterable<Tag> tags = (result["tags"] as List<dynamic>).map(
                  (data) => Tag.fromJson(data as Map<String, dynamic>),
                );
                release.tags.addAll(tags);

                return release;
              }

              return null;
            }))
        .toList();
    List<Release?> temp = await Future.wait(futures);

    await pool.close();
    temp.removeWhere((r) => r == null);
    releases = temp.cast<Release>();


    printDebug(releases.length);
    return releases;
  }

  Future<T> describeEntity<T extends Entity>(T entity) async {
    final String prompt = entity.toPrompt();
    printDebug(prompt);
    final GenerativeModel model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: ApiResponse.tagsSchema
      ),
    );

    final GenerateContentResponse response = await model.generateContent(
      [Content.text(prompt)],
    );

    Set<Tag> tags = {};
    List<dynamic> results = jsonDecode(response.text!);

    for (Map<String, dynamic> result in results) {
      tags.add(Tag.fromJson(result));
    }

    entity.tags.clear();
    entity.tags.addAll(tags);

    return entity;
  }
}
