import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api_service.dart';
import '../models/idea_model.dart';

final ideaProvider = StateNotifierProvider<IdeaNotifier, AsyncValue<List<IdeaModel>>>((ref) {
  return IdeaNotifier();
});

class IdeaNotifier extends StateNotifier<AsyncValue<List<IdeaModel>>> {
  IdeaNotifier() : super(const AsyncValue.loading()) {
    fetchIdeas();
  }

  Future<void> fetchIdeas({int? categoryId}) async {
    state = const AsyncValue.loading();
    try {
      final endpoint = categoryId != null ? 'api/Idea?category=$categoryId' : 'api/Idea';
      final response = await ApiService.get(endpoint);
      if (response != null && response is List) {
        final ideas = response.map((data) => IdeaModel.fromJson(data)).toList();
        state = AsyncValue.data(ideas);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createIdea(Map<String, dynamic> data) async {
    try {
      final result = await ApiService.post('api/Idea', data);
      if (result != null) {
        fetchIdeas(); // Listeyi yenile
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
