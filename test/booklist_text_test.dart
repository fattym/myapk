import 'package:flutter_test/flutter_test.dart';
import 'package:mybidhaa/utils/booklist_text.dart';

void main() {
  test('cleans OCR lines from a booklist photo', () {
    final out = cleanBooklistLines([
      'GRADE 3 BOOKLIST',
      'Name: ______',
      '1. KLB Visionary Mathematical Activities Grade 3',
      '2) Longhorn English GD3  ',
      '450',
      'KES 520.00',
      'Oxford  Kiswahili   Safi',
      'oxford kiswahili safi',
      '3 - Moran Bible Stories',
    ]);
    expect(out, [
      'KLB Visionary Mathematical Activities Grade 3',
      'Longhorn English GD3',
      'Oxford Kiswahili Safi',
      'Moran Bible Stories',
    ]);
  });

  test('scores catalogue matches by word overlap', () {
    expect(
      matchScore('Moran Bible Stories', 'MORAN BIBLE STORIES JUDAS ISCARIOT 1'),
      1.0,
    );
    expect(
      matchScore('Oxford Kiswahili Safi', 'KLB Eye Lower Primary Kiswahili GD3 (Rtd)'),
      lessThan(0.5),
    );
  });
}
