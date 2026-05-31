import 'package:flutter_test/flutter_test.dart';
import 'package:raisa_diary/core/utils/emotion_utils.dart';

void main() {
  test('emotion emoji mapping', () {
    expect(EmotionUtils.emojiFor('happy'), '😊');
    expect(EmotionUtils.emojiFor('sad'), '😢');
    expect(EmotionUtils.emojiFor(null), '💭');
  });
}
