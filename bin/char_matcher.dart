import 'dart:io';
import 'dart:math';

import 'package:benchmark/benchmark.dart';
import 'package:more/char_matcher.dart';
import 'package:more/collection.dart';
import 'package:more/src/char_matcher/basic/range.dart';
import 'package:more/src/char_matcher/custom/optimize.dart';

final random = Random(42);
final chars = [
  ...List.generate(200, (i) => random.nextInt(0x10ffff)),
  ...List.generate(300, (i) => random.nextInt(0xffff)),
  ...List.generate(500, (i) => random.nextInt(0xff)),
]..shuffle(random);

bool Function() loop(bool Function(int) matcher) => () {
      var value = false;
      for (final char in chars) {
        value = value == matcher(char);
      }
      return value;
    };

void main() {
  for (final char in chars) {
    final results = [
      matchBase(char),
      matchRange(char),
      matchIfThen(char),
      matchSwitchOr(char),
      matchSwitchCase(char),
    ];
    if (!results.every((each) => each) && !results.every((each) => !each)) {
      stdout.writeln('WARNING: U+${char.toRadixString(16)} --> '
          '${results.join(', ')}');
    }
  }

  experiments(
    control: loop(matchBase),
    experiments: {
      'range': loop(matchRange),
      'if-then': loop(matchIfThen),
      'switch-or': loop(matchSwitchOr),
      'switch-case': loop(matchSwitchCase),
    },
  );
}

final matchBase = UnicodeCharMatcher.symbol().match;

const ranges = [
  36, 36, 162, 165, 1423, 1423, 1547, 1547, 2046, 2047, 2546, 2547, 2555, 2555,
  2801, 2801, 3065, 3065, 3647, 3647, 6107, 6107, 8352, 8384, 43064, 43064,
  65020, 65020, 65129, 65129, 65284, 65284, 65504, 65505, 65509, 65510, 73693,
  73696, 123647, 123647, 126128, 126128,
  94, 94, 96, 96, 168, 168, 175, 175, 180, 180, 184, 184, 706, 709, 722, 735,
  741, 747, 749, 749, 751, 767, 885, 885, 900, 901, 2184, 2184, 8125, 8125,
  8127, 8129, 8141, 8143, 8157, 8159, 8173, 8175, 8189, 8190, 12443, 12444,
  42752, 42774, 42784, 42785, 42889, 42890, 43867, 43867, 43882, 43883, 64434,
  64450, 65342, 65342, 65344, 65344, 65507, 65507, 127995, 127999,
  43, 43, 60, 62, 124, 124, 126, 126, 172, 172, 177, 177, 215, 215, 247, 247,
  1014, 1014, 1542, 1544, 8260, 8260, 8274, 8274, 8314, 8316, 8330, 8332, 8472,
  8472, 8512, 8516, 8523, 8523, 8592, 8596, 8602, 8603, 8608, 8608, 8611, 8611,
  8614, 8614, 8622, 8622, 8654, 8655, 8658, 8658, 8660, 8660, 8692, 8959, 8992,
  8993, 9084, 9084, 9115, 9139, 9180, 9185, 9655, 9655, 9665, 9665, 9720, 9727,
  9839, 9839, 10176, 10180, 10183, 10213, 10224, 10239, 10496, 10626, 10649,
  10711, 10716, 10747, 10750, 11007, 11056, 11076, 11079, 11084, 64297, 64297,
  65122, 65122, 65124, 65126, 65291, 65291, 65308, 65310, 65372, 65372, 65374,
  65374, 65506, 65506, 65513, 65516, 120513, 120513, 120539, 120539, 120571,
  120571, 120597, 120597, 120629, 120629, 120655, 120655, 120687, 120687,
  120713, 120713, 120745, 120745, 120771, 120771, 126704, 126705,
  166, 166, 169, 169, 174, 174, 176, 176, 1154, 1154, 1421, 1422, 1550, 1551,
  1758, 1758, 1769, 1769, 1789, 1790, 2038, 2038, 2554, 2554, 2928, 2928, 3059,
  3064, 3066, 3066, 3199, 3199, 3407, 3407, 3449, 3449, 3841, 3843, 3859, 3859,
  3861, 3863, 3866, 3871, 3892, 3892, 3894, 3894, 3896, 3896, 4030, 4037, 4039,
  4044, 4046, 4047, 4053, 4056, 4254, 4255, 5008, 5017, 5741, 5741, 6464, 6464,
  6622, 6655, 7009, 7018, 7028, 7036, 8448, 8449, 8451, 8454, 8456, 8457, 8468,
  8468, 8470, 8471, 8478, 8483, 8485, 8485, 8487, 8487, 8489, 8489, 8494, 8494,
  8506, 8507, 8522, 8522, 8524, 8525, 8527, 8527, 8586, 8587, 8597, 8601, 8604,
  8607, 8609, 8610, 8612, 8613, 8615, 8621, 8623, 8653, 8656, 8657, 8659, 8659,
  8661, 8691, 8960, 8967, 8972, 8991, 8994, 9000, 9003, 9083, 9085, 9114, 9140,
  9179, 9186, 9254, 9280, 9290, 9372, 9449, 9472, 9654, 9656, 9664, 9666, 9719,
  9728, 9838, 9840, 10087, 10132, 10175, 10240, 10495, 11008, 11055, 11077,
  11078, 11085, 11123, 11126, 11157, 11159, 11263, 11493, 11498, 11856, 11857,
  11904, 11929, 11931, 12019, 12032, 12245, 12272, 12287, 12292, 12292, 12306,
  12307, 12320, 12320, 12342, 12343, 12350, 12351, 12688, 12689, 12694, 12703,
  12736, 12771, 12783, 12783, 12800, 12830, 12842, 12871, 12880, 12880, 12896,
  12927, 12938, 12976, 12992, 13311, 19904, 19967, 42128, 42182, 43048, 43051,
  43062, 43063, 43065, 43065, 43639, 43641, 64832, 64847, 64975, 64975, 65021,
  65023, 65508, 65508, 65512, 65512, 65517, 65518, 65532, 65533, 65847, 65855,
  65913, 65929, 65932, 65934, 65936, 65948, 65952, 65952, 66000, 66044, 67703,
  67704, 68296, 68296, 71487, 71487, 73685, 73692, 73697, 73713, 92988, 92991,
  92997, 92997, 113820, 113820, 118608, 118723, 118784, 119029, 119040, 119078,
  119081, 119140, 119146, 119148, 119171, 119172, 119180, 119209, 119214,
  119274, 119296, 119361, 119365, 119365, 119552, 119638, 120832, 121343,
  121399, 121402, 121453, 121460, 121462, 121475, 121477, 121478, 123215,
  123215, 126124, 126124, 126254, 126254, 126976, 127019, 127024, 127123,
  127136, 127150, 127153, 127167, 127169, 127183, 127185, 127221, 127245,
  127405, 127462, 127490, 127504, 127547, 127552, 127560, 127568, 127569,
  127584, 127589, 127744, 127994, 128000, 128727, 128732, 128748, 128752,
  128764, 128768, 128886, 128891, 128985, 128992, 129003, 129008, 129008,
  129024, 129035, 129040, 129095, 129104, 129113, 129120, 129159, 129168,
  129197, 129200, 129201, 129280, 129619, 129632, 129645, 129648, 129660,
  129664, 129672, 129680, 129725, 129727, 129733, 129742, 129755, 129760,
  129768, 129776, 129784, 129792, 129938, 129940, 129994 //
];
final matchRange = optimize(ranges
    .chunked(2)
    .map((range) => RangeCharMatcher(range.first, range.last))).match;

bool matchIfThen(int value) {
  if (value <= 12703) {
    if (value <= 6107) {
      if (value <= 1758) {
        if (value <= 215) {
          if (value <= 126) {
            if (value <= 62) {
              if (value <= 36) {
                return 36 <= value;
              } else if (43 <= value) {
                if (value <= 43) {
                  return true;
                } else if (60 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (94 <= value) {
              if (value <= 96) {
                if (value <= 94) {
                  return true;
                } else if (96 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (124 <= value) {
                if (value <= 124) {
                  return true;
                } else if (126 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (162 <= value) {
            if (value <= 172) {
              if (value <= 166) {
                return true;
              } else if (168 <= value) {
                if (value <= 169) {
                  return true;
                } else if (172 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (174 <= value) {
              if (value <= 180) {
                if (value <= 177) {
                  return true;
                } else if (180 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (184 <= value) {
                if (value <= 184) {
                  return true;
                } else if (215 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (247 <= value) {
          if (value <= 885) {
            if (value <= 735) {
              if (value <= 247) {
                return true;
              } else if (706 <= value) {
                if (value <= 709) {
                  return true;
                } else if (722 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (741 <= value) {
              if (value <= 749) {
                if (value <= 747) {
                  return true;
                } else if (749 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (751 <= value) {
                if (value <= 767) {
                  return true;
                } else if (885 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (900 <= value) {
            if (value <= 1423) {
              if (value <= 1014) {
                if (value <= 901) {
                  return true;
                } else if (1014 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (1154 <= value) {
                if (value <= 1154) {
                  return true;
                } else if (1421 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (1542 <= value) {
              if (value <= 1547) {
                if (value <= 1544) {
                  return true;
                } else if (1547 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (1550 <= value) {
                if (value <= 1551) {
                  return true;
                } else if (1758 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else if (1769 <= value) {
        if (value <= 3647) {
          if (value <= 2555) {
            if (value <= 2038) {
              if (value <= 1769) {
                return true;
              } else if (1789 <= value) {
                if (value <= 1790) {
                  return true;
                } else if (2038 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (2046 <= value) {
              if (value <= 2184) {
                if (value <= 2047) {
                  return true;
                } else if (2184 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (2546 <= value) {
                if (value <= 2547) {
                  return true;
                } else if (2554 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (2801 <= value) {
            if (value <= 3066) {
              if (value <= 2801) {
                return true;
              } else if (2928 <= value) {
                if (value <= 2928) {
                  return true;
                } else if (3059 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (3199 <= value) {
              if (value <= 3407) {
                if (value <= 3199) {
                  return true;
                } else if (3407 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (3449 <= value) {
                if (value <= 3449) {
                  return true;
                } else if (3647 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (3841 <= value) {
          if (value <= 3896) {
            if (value <= 3863) {
              if (value <= 3843) {
                return true;
              } else if (3859 <= value) {
                if (value <= 3859) {
                  return true;
                } else if (3861 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (3866 <= value) {
              if (value <= 3892) {
                if (value <= 3871) {
                  return true;
                } else if (3892 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (3894 <= value) {
                if (value <= 3894) {
                  return true;
                } else if (3896 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (4030 <= value) {
            if (value <= 4056) {
              if (value <= 4044) {
                if (value <= 4037) {
                  return true;
                } else if (4039 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (4046 <= value) {
                if (value <= 4047) {
                  return true;
                } else if (4053 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (4254 <= value) {
              if (value <= 5017) {
                if (value <= 4255) {
                  return true;
                } else if (5008 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (5741 <= value) {
                if (value <= 5741) {
                  return true;
                } else if (6107 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (6464 <= value) {
      if (value <= 8527) {
        if (value <= 8332) {
          if (value <= 8143) {
            if (value <= 7018) {
              if (value <= 6464) {
                return true;
              } else if (6622 <= value) {
                if (value <= 6655) {
                  return true;
                } else if (7009 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (7028 <= value) {
              if (value <= 8125) {
                if (value <= 7036) {
                  return true;
                } else if (8125 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (8127 <= value) {
                if (value <= 8129) {
                  return true;
                } else if (8141 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (8157 <= value) {
            if (value <= 8190) {
              if (value <= 8159) {
                return true;
              } else if (8173 <= value) {
                if (value <= 8175) {
                  return true;
                } else if (8189 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (8260 <= value) {
              if (value <= 8274) {
                if (value <= 8260) {
                  return true;
                } else if (8274 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (8314 <= value) {
                if (value <= 8316) {
                  return true;
                } else if (8330 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (8352 <= value) {
          if (value <= 8483) {
            if (value <= 8454) {
              if (value <= 8384) {
                return true;
              } else if (8448 <= value) {
                if (value <= 8449) {
                  return true;
                } else if (8451 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (8456 <= value) {
              if (value <= 8468) {
                if (value <= 8457) {
                  return true;
                } else if (8468 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (8470 <= value) {
                if (value <= 8472) {
                  return true;
                } else if (8478 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (8485 <= value) {
            if (value <= 8494) {
              if (value <= 8487) {
                if (value <= 8485) {
                  return true;
                } else if (8487 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (8489 <= value) {
                if (value <= 8489) {
                  return true;
                } else if (8494 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (8506 <= value) {
              if (value <= 8516) {
                if (value <= 8507) {
                  return true;
                } else if (8512 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (8522 <= value) {
                if (value <= 8525) {
                  return true;
                } else if (8527 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else if (8586 <= value) {
        if (value <= 11157) {
          if (value <= 10087) {
            if (value <= 9000) {
              if (value <= 8587) {
                return true;
              } else if (8592 <= value) {
                if (value <= 8967) {
                  return true;
                } else if (8972 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (9003 <= value) {
              if (value <= 9290) {
                if (value <= 9254) {
                  return true;
                } else if (9280 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (9372 <= value) {
                if (value <= 9449) {
                  return true;
                } else if (9472 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (10132 <= value) {
            if (value <= 10626) {
              if (value <= 10180) {
                return true;
              } else if (10183 <= value) {
                if (value <= 10213) {
                  return true;
                } else if (10224 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (10649 <= value) {
              if (value <= 10747) {
                if (value <= 10711) {
                  return true;
                } else if (10716 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (10750 <= value) {
                if (value <= 11123) {
                  return true;
                } else if (11126 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (11159 <= value) {
          if (value <= 12287) {
            if (value <= 11857) {
              if (value <= 11263) {
                return true;
              } else if (11493 <= value) {
                if (value <= 11498) {
                  return true;
                } else if (11856 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (11904 <= value) {
              if (value <= 12019) {
                if (value <= 11929) {
                  return true;
                } else if (11931 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (12032 <= value) {
                if (value <= 12245) {
                  return true;
                } else if (12272 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (12292 <= value) {
            if (value <= 12343) {
              if (value <= 12307) {
                if (value <= 12292) {
                  return true;
                } else if (12306 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (12320 <= value) {
                if (value <= 12320) {
                  return true;
                } else if (12342 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (12350 <= value) {
              if (value <= 12444) {
                if (value <= 12351) {
                  return true;
                } else if (12443 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (12688 <= value) {
                if (value <= 12689) {
                  return true;
                } else if (12694 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else if (12736 <= value) {
    if (value <= 119361) {
      if (value <= 65310) {
        if (value <= 43051) {
          if (value <= 12976) {
            if (value <= 12830) {
              if (value <= 12771) {
                return true;
              } else if (12783 <= value) {
                if (value <= 12783) {
                  return true;
                } else if (12800 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (12842 <= value) {
              if (value <= 12880) {
                if (value <= 12871) {
                  return true;
                } else if (12880 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (12896 <= value) {
                if (value <= 12927) {
                  return true;
                } else if (12938 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (12992 <= value) {
            if (value <= 42182) {
              if (value <= 13311) {
                return true;
              } else if (19904 <= value) {
                if (value <= 19967) {
                  return true;
                } else if (42128 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (42752 <= value) {
              if (value <= 42785) {
                if (value <= 42774) {
                  return true;
                } else if (42784 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (42889 <= value) {
                if (value <= 42890) {
                  return true;
                } else if (43048 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (43062 <= value) {
          if (value <= 64847) {
            if (value <= 43867) {
              if (value <= 43065) {
                return true;
              } else if (43639 <= value) {
                if (value <= 43641) {
                  return true;
                } else if (43867 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (43882 <= value) {
              if (value <= 64297) {
                if (value <= 43883) {
                  return true;
                } else if (64297 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (64434 <= value) {
                if (value <= 64450) {
                  return true;
                } else if (64832 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (64975 <= value) {
            if (value <= 65126) {
              if (value <= 65023) {
                if (value <= 64975) {
                  return true;
                } else if (65020 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (65122 <= value) {
                if (value <= 65122) {
                  return true;
                } else if (65124 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (65129 <= value) {
              if (value <= 65284) {
                if (value <= 65129) {
                  return true;
                } else if (65284 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (65291 <= value) {
                if (value <= 65291) {
                  return true;
                } else if (65308 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else if (65342 <= value) {
        if (value <= 67704) {
          if (value <= 65533) {
            if (value <= 65372) {
              if (value <= 65342) {
                return true;
              } else if (65344 <= value) {
                if (value <= 65344) {
                  return true;
                } else if (65372 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (65374 <= value) {
              if (value <= 65510) {
                if (value <= 65374) {
                  return true;
                } else if (65504 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (65512 <= value) {
                if (value <= 65518) {
                  return true;
                } else if (65532 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (65847 <= value) {
            if (value <= 65934) {
              if (value <= 65855) {
                return true;
              } else if (65913 <= value) {
                if (value <= 65929) {
                  return true;
                } else if (65932 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (65936 <= value) {
              if (value <= 65952) {
                if (value <= 65948) {
                  return true;
                } else if (65952 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (66000 <= value) {
                if (value <= 66044) {
                  return true;
                } else if (67703 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (68296 <= value) {
          if (value <= 118723) {
            if (value <= 73713) {
              if (value <= 68296) {
                return true;
              } else if (71487 <= value) {
                if (value <= 71487) {
                  return true;
                } else if (73685 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (92988 <= value) {
              if (value <= 92997) {
                if (value <= 92991) {
                  return true;
                } else if (92997 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (113820 <= value) {
                if (value <= 113820) {
                  return true;
                } else if (118608 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (118784 <= value) {
            if (value <= 119148) {
              if (value <= 119078) {
                if (value <= 119029) {
                  return true;
                } else if (119040 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (119081 <= value) {
                if (value <= 119140) {
                  return true;
                } else if (119146 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (119171 <= value) {
              if (value <= 119209) {
                if (value <= 119172) {
                  return true;
                } else if (119180 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (119214 <= value) {
                if (value <= 119274) {
                  return true;
                } else if (119296 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (119365 <= value) {
      if (value <= 127221) {
        if (value <= 121402) {
          if (value <= 120629) {
            if (value <= 120513) {
              if (value <= 119365) {
                return true;
              } else if (119552 <= value) {
                if (value <= 119638) {
                  return true;
                } else if (120513 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (120539 <= value) {
              if (value <= 120571) {
                if (value <= 120539) {
                  return true;
                } else if (120571 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (120597 <= value) {
                if (value <= 120597) {
                  return true;
                } else if (120629 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (120655 <= value) {
            if (value <= 120713) {
              if (value <= 120655) {
                return true;
              } else if (120687 <= value) {
                if (value <= 120687) {
                  return true;
                } else if (120713 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (120745 <= value) {
              if (value <= 120771) {
                if (value <= 120745) {
                  return true;
                } else if (120771 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (120832 <= value) {
                if (value <= 121343) {
                  return true;
                } else if (121399 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (121453 <= value) {
          if (value <= 126128) {
            if (value <= 121478) {
              if (value <= 121460) {
                return true;
              } else if (121462 <= value) {
                if (value <= 121475) {
                  return true;
                } else if (121477 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (123215 <= value) {
              if (value <= 123647) {
                if (value <= 123215) {
                  return true;
                } else if (123647 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (126124 <= value) {
                if (value <= 126124) {
                  return true;
                } else if (126128 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (126254 <= value) {
            if (value <= 127123) {
              if (value <= 126705) {
                if (value <= 126254) {
                  return true;
                } else if (126704 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (126976 <= value) {
                if (value <= 127019) {
                  return true;
                } else if (127024 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (127136 <= value) {
              if (value <= 127167) {
                if (value <= 127150) {
                  return true;
                } else if (127153 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (127169 <= value) {
                if (value <= 127183) {
                  return true;
                } else if (127185 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else if (127245 <= value) {
        if (value <= 129095) {
          if (value <= 128727) {
            if (value <= 127547) {
              if (value <= 127405) {
                return true;
              } else if (127462 <= value) {
                if (value <= 127490) {
                  return true;
                } else if (127504 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (127552 <= value) {
              if (value <= 127569) {
                if (value <= 127560) {
                  return true;
                } else if (127568 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (127584 <= value) {
                if (value <= 127589) {
                  return true;
                } else if (127744 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (128732 <= value) {
            if (value <= 128985) {
              if (value <= 128764) {
                if (value <= 128748) {
                  return true;
                } else if (128752 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (128768 <= value) {
                if (value <= 128886) {
                  return true;
                } else if (128891 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (128992 <= value) {
              if (value <= 129008) {
                if (value <= 129003) {
                  return true;
                } else if (129008 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (129024 <= value) {
                if (value <= 129035) {
                  return true;
                } else if (129040 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else if (129104 <= value) {
          if (value <= 129660) {
            if (value <= 129197) {
              if (value <= 129113) {
                return true;
              } else if (129120 <= value) {
                if (value <= 129159) {
                  return true;
                } else if (129168 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (129200 <= value) {
              if (value <= 129619) {
                if (value <= 129201) {
                  return true;
                } else if (129280 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (129632 <= value) {
                if (value <= 129645) {
                  return true;
                } else if (129648 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else if (129664 <= value) {
            if (value <= 129755) {
              if (value <= 129725) {
                if (value <= 129672) {
                  return true;
                } else if (129680 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (129727 <= value) {
                if (value <= 129733) {
                  return true;
                } else if (129742 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else if (129760 <= value) {
              if (value <= 129784) {
                if (value <= 129768) {
                  return true;
                } else if (129776 <= value) {
                  return true;
                } else {
                  return false;
                }
              } else if (129792 <= value) {
                if (value <= 129938) {
                  return true;
                } else if (129940 <= value) {
                  return value <= 129994;
                } else {
                  return false;
                }
              } else {
                return false;
              }
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

bool matchSwitchOr(int value) => switch (value) {
      (== 36) ||
      (== 43) ||
      (>= 60 && <= 62) ||
      (== 94) ||
      (== 96) ||
      (== 124) ||
      (== 126) ||
      (>= 162 && <= 166) ||
      (>= 168 && <= 169) ||
      (== 172) ||
      (>= 174 && <= 177) ||
      (== 180) ||
      (== 184) ||
      (== 215) ||
      (== 247) ||
      (>= 706 && <= 709) ||
      (>= 722 && <= 735) ||
      (>= 741 && <= 747) ||
      (== 749) ||
      (>= 751 && <= 767) ||
      (== 885) ||
      (>= 900 && <= 901) ||
      (== 1014) ||
      (== 1154) ||
      (>= 1421 && <= 1423) ||
      (>= 1542 && <= 1544) ||
      (== 1547) ||
      (>= 1550 && <= 1551) ||
      (== 1758) ||
      (== 1769) ||
      (>= 1789 && <= 1790) ||
      (== 2038) ||
      (>= 2046 && <= 2047) ||
      (== 2184) ||
      (>= 2546 && <= 2547) ||
      (>= 2554 && <= 2555) ||
      (== 2801) ||
      (== 2928) ||
      (>= 3059 && <= 3066) ||
      (== 3199) ||
      (== 3407) ||
      (== 3449) ||
      (== 3647) ||
      (>= 3841 && <= 3843) ||
      (== 3859) ||
      (>= 3861 && <= 3863) ||
      (>= 3866 && <= 3871) ||
      (== 3892) ||
      (== 3894) ||
      (== 3896) ||
      (>= 4030 && <= 4037) ||
      (>= 4039 && <= 4044) ||
      (>= 4046 && <= 4047) ||
      (>= 4053 && <= 4056) ||
      (>= 4254 && <= 4255) ||
      (>= 5008 && <= 5017) ||
      (== 5741) ||
      (== 6107) ||
      (== 6464) ||
      (>= 6622 && <= 6655) ||
      (>= 7009 && <= 7018) ||
      (>= 7028 && <= 7036) ||
      (== 8125) ||
      (>= 8127 && <= 8129) ||
      (>= 8141 && <= 8143) ||
      (>= 8157 && <= 8159) ||
      (>= 8173 && <= 8175) ||
      (>= 8189 && <= 8190) ||
      (== 8260) ||
      (== 8274) ||
      (>= 8314 && <= 8316) ||
      (>= 8330 && <= 8332) ||
      (>= 8352 && <= 8384) ||
      (>= 8448 && <= 8449) ||
      (>= 8451 && <= 8454) ||
      (>= 8456 && <= 8457) ||
      (== 8468) ||
      (>= 8470 && <= 8472) ||
      (>= 8478 && <= 8483) ||
      (== 8485) ||
      (== 8487) ||
      (== 8489) ||
      (== 8494) ||
      (>= 8506 && <= 8507) ||
      (>= 8512 && <= 8516) ||
      (>= 8522 && <= 8525) ||
      (== 8527) ||
      (>= 8586 && <= 8587) ||
      (>= 8592 && <= 8967) ||
      (>= 8972 && <= 9000) ||
      (>= 9003 && <= 9254) ||
      (>= 9280 && <= 9290) ||
      (>= 9372 && <= 9449) ||
      (>= 9472 && <= 10087) ||
      (>= 10132 && <= 10180) ||
      (>= 10183 && <= 10213) ||
      (>= 10224 && <= 10626) ||
      (>= 10649 && <= 10711) ||
      (>= 10716 && <= 10747) ||
      (>= 10750 && <= 11123) ||
      (>= 11126 && <= 11157) ||
      (>= 11159 && <= 11263) ||
      (>= 11493 && <= 11498) ||
      (>= 11856 && <= 11857) ||
      (>= 11904 && <= 11929) ||
      (>= 11931 && <= 12019) ||
      (>= 12032 && <= 12245) ||
      (>= 12272 && <= 12287) ||
      (== 12292) ||
      (>= 12306 && <= 12307) ||
      (== 12320) ||
      (>= 12342 && <= 12343) ||
      (>= 12350 && <= 12351) ||
      (>= 12443 && <= 12444) ||
      (>= 12688 && <= 12689) ||
      (>= 12694 && <= 12703) ||
      (>= 12736 && <= 12771) ||
      (== 12783) ||
      (>= 12800 && <= 12830) ||
      (>= 12842 && <= 12871) ||
      (== 12880) ||
      (>= 12896 && <= 12927) ||
      (>= 12938 && <= 12976) ||
      (>= 12992 && <= 13311) ||
      (>= 19904 && <= 19967) ||
      (>= 42128 && <= 42182) ||
      (>= 42752 && <= 42774) ||
      (>= 42784 && <= 42785) ||
      (>= 42889 && <= 42890) ||
      (>= 43048 && <= 43051) ||
      (>= 43062 && <= 43065) ||
      (>= 43639 && <= 43641) ||
      (== 43867) ||
      (>= 43882 && <= 43883) ||
      (== 64297) ||
      (>= 64434 && <= 64450) ||
      (>= 64832 && <= 64847) ||
      (== 64975) ||
      (>= 65020 && <= 65023) ||
      (== 65122) ||
      (>= 65124 && <= 65126) ||
      (== 65129) ||
      (== 65284) ||
      (== 65291) ||
      (>= 65308 && <= 65310) ||
      (== 65342) ||
      (== 65344) ||
      (== 65372) ||
      (== 65374) ||
      (>= 65504 && <= 65510) ||
      (>= 65512 && <= 65518) ||
      (>= 65532 && <= 65533) ||
      (>= 65847 && <= 65855) ||
      (>= 65913 && <= 65929) ||
      (>= 65932 && <= 65934) ||
      (>= 65936 && <= 65948) ||
      (== 65952) ||
      (>= 66000 && <= 66044) ||
      (>= 67703 && <= 67704) ||
      (== 68296) ||
      (== 71487) ||
      (>= 73685 && <= 73713) ||
      (>= 92988 && <= 92991) ||
      (== 92997) ||
      (== 113820) ||
      (>= 118608 && <= 118723) ||
      (>= 118784 && <= 119029) ||
      (>= 119040 && <= 119078) ||
      (>= 119081 && <= 119140) ||
      (>= 119146 && <= 119148) ||
      (>= 119171 && <= 119172) ||
      (>= 119180 && <= 119209) ||
      (>= 119214 && <= 119274) ||
      (>= 119296 && <= 119361) ||
      (== 119365) ||
      (>= 119552 && <= 119638) ||
      (== 120513) ||
      (== 120539) ||
      (== 120571) ||
      (== 120597) ||
      (== 120629) ||
      (== 120655) ||
      (== 120687) ||
      (== 120713) ||
      (== 120745) ||
      (== 120771) ||
      (>= 120832 && <= 121343) ||
      (>= 121399 && <= 121402) ||
      (>= 121453 && <= 121460) ||
      (>= 121462 && <= 121475) ||
      (>= 121477 && <= 121478) ||
      (== 123215) ||
      (== 123647) ||
      (== 126124) ||
      (== 126128) ||
      (== 126254) ||
      (>= 126704 && <= 126705) ||
      (>= 126976 && <= 127019) ||
      (>= 127024 && <= 127123) ||
      (>= 127136 && <= 127150) ||
      (>= 127153 && <= 127167) ||
      (>= 127169 && <= 127183) ||
      (>= 127185 && <= 127221) ||
      (>= 127245 && <= 127405) ||
      (>= 127462 && <= 127490) ||
      (>= 127504 && <= 127547) ||
      (>= 127552 && <= 127560) ||
      (>= 127568 && <= 127569) ||
      (>= 127584 && <= 127589) ||
      (>= 127744 && <= 128727) ||
      (>= 128732 && <= 128748) ||
      (>= 128752 && <= 128764) ||
      (>= 128768 && <= 128886) ||
      (>= 128891 && <= 128985) ||
      (>= 128992 && <= 129003) ||
      (== 129008) ||
      (>= 129024 && <= 129035) ||
      (>= 129040 && <= 129095) ||
      (>= 129104 && <= 129113) ||
      (>= 129120 && <= 129159) ||
      (>= 129168 && <= 129197) ||
      (>= 129200 && <= 129201) ||
      (>= 129280 && <= 129619) ||
      (>= 129632 && <= 129645) ||
      (>= 129648 && <= 129660) ||
      (>= 129664 && <= 129672) ||
      (>= 129680 && <= 129725) ||
      (>= 129727 && <= 129733) ||
      (>= 129742 && <= 129755) ||
      (>= 129760 && <= 129768) ||
      (>= 129776 && <= 129784) ||
      (>= 129792 && <= 129938) ||
      (>= 129940 && <= 129994) =>
        true,
      _ => false,
    };

bool matchSwitchCase(int value) => switch (value) {
      == 36 => true,
      == 43 => true,
      >= 60 && <= 62 => true,
      == 94 => true,
      == 96 => true,
      == 124 => true,
      == 126 => true,
      >= 162 && <= 166 => true,
      >= 168 && <= 169 => true,
      == 172 => true,
      >= 174 && <= 177 => true,
      == 180 => true,
      == 184 => true,
      == 215 => true,
      == 247 => true,
      >= 706 && <= 709 => true,
      >= 722 && <= 735 => true,
      >= 741 && <= 747 => true,
      == 749 => true,
      >= 751 && <= 767 => true,
      == 885 => true,
      >= 900 && <= 901 => true,
      == 1014 => true,
      == 1154 => true,
      >= 1421 && <= 1423 => true,
      >= 1542 && <= 1544 => true,
      == 1547 => true,
      >= 1550 && <= 1551 => true,
      == 1758 => true,
      == 1769 => true,
      >= 1789 && <= 1790 => true,
      == 2038 => true,
      >= 2046 && <= 2047 => true,
      == 2184 => true,
      >= 2546 && <= 2547 => true,
      >= 2554 && <= 2555 => true,
      == 2801 => true,
      == 2928 => true,
      >= 3059 && <= 3066 => true,
      == 3199 => true,
      == 3407 => true,
      == 3449 => true,
      == 3647 => true,
      >= 3841 && <= 3843 => true,
      == 3859 => true,
      >= 3861 && <= 3863 => true,
      >= 3866 && <= 3871 => true,
      == 3892 => true,
      == 3894 => true,
      == 3896 => true,
      >= 4030 && <= 4037 => true,
      >= 4039 && <= 4044 => true,
      >= 4046 && <= 4047 => true,
      >= 4053 && <= 4056 => true,
      >= 4254 && <= 4255 => true,
      >= 5008 && <= 5017 => true,
      == 5741 => true,
      == 6107 => true,
      == 6464 => true,
      >= 6622 && <= 6655 => true,
      >= 7009 && <= 7018 => true,
      >= 7028 && <= 7036 => true,
      == 8125 => true,
      >= 8127 && <= 8129 => true,
      >= 8141 && <= 8143 => true,
      >= 8157 && <= 8159 => true,
      >= 8173 && <= 8175 => true,
      >= 8189 && <= 8190 => true,
      == 8260 => true,
      == 8274 => true,
      >= 8314 && <= 8316 => true,
      >= 8330 && <= 8332 => true,
      >= 8352 && <= 8384 => true,
      >= 8448 && <= 8449 => true,
      >= 8451 && <= 8454 => true,
      >= 8456 && <= 8457 => true,
      == 8468 => true,
      >= 8470 && <= 8472 => true,
      >= 8478 && <= 8483 => true,
      == 8485 => true,
      == 8487 => true,
      == 8489 => true,
      == 8494 => true,
      >= 8506 && <= 8507 => true,
      >= 8512 && <= 8516 => true,
      >= 8522 && <= 8525 => true,
      == 8527 => true,
      >= 8586 && <= 8587 => true,
      >= 8592 && <= 8967 => true,
      >= 8972 && <= 9000 => true,
      >= 9003 && <= 9254 => true,
      >= 9280 && <= 9290 => true,
      >= 9372 && <= 9449 => true,
      >= 9472 && <= 10087 => true,
      >= 10132 && <= 10180 => true,
      >= 10183 && <= 10213 => true,
      >= 10224 && <= 10626 => true,
      >= 10649 && <= 10711 => true,
      >= 10716 && <= 10747 => true,
      >= 10750 && <= 11123 => true,
      >= 11126 && <= 11157 => true,
      >= 11159 && <= 11263 => true,
      >= 11493 && <= 11498 => true,
      >= 11856 && <= 11857 => true,
      >= 11904 && <= 11929 => true,
      >= 11931 && <= 12019 => true,
      >= 12032 && <= 12245 => true,
      >= 12272 && <= 12287 => true,
      == 12292 => true,
      >= 12306 && <= 12307 => true,
      == 12320 => true,
      >= 12342 && <= 12343 => true,
      >= 12350 && <= 12351 => true,
      >= 12443 && <= 12444 => true,
      >= 12688 && <= 12689 => true,
      >= 12694 && <= 12703 => true,
      >= 12736 && <= 12771 => true,
      == 12783 => true,
      >= 12800 && <= 12830 => true,
      >= 12842 && <= 12871 => true,
      == 12880 => true,
      >= 12896 && <= 12927 => true,
      >= 12938 && <= 12976 => true,
      >= 12992 && <= 13311 => true,
      >= 19904 && <= 19967 => true,
      >= 42128 && <= 42182 => true,
      >= 42752 && <= 42774 => true,
      >= 42784 && <= 42785 => true,
      >= 42889 && <= 42890 => true,
      >= 43048 && <= 43051 => true,
      >= 43062 && <= 43065 => true,
      >= 43639 && <= 43641 => true,
      == 43867 => true,
      >= 43882 && <= 43883 => true,
      == 64297 => true,
      >= 64434 && <= 64450 => true,
      >= 64832 && <= 64847 => true,
      == 64975 => true,
      >= 65020 && <= 65023 => true,
      == 65122 => true,
      >= 65124 && <= 65126 => true,
      == 65129 => true,
      == 65284 => true,
      == 65291 => true,
      >= 65308 && <= 65310 => true,
      == 65342 => true,
      == 65344 => true,
      == 65372 => true,
      == 65374 => true,
      >= 65504 && <= 65510 => true,
      >= 65512 && <= 65518 => true,
      >= 65532 && <= 65533 => true,
      >= 65847 && <= 65855 => true,
      >= 65913 && <= 65929 => true,
      >= 65932 && <= 65934 => true,
      >= 65936 && <= 65948 => true,
      == 65952 => true,
      >= 66000 && <= 66044 => true,
      >= 67703 && <= 67704 => true,
      == 68296 => true,
      == 71487 => true,
      >= 73685 && <= 73713 => true,
      >= 92988 && <= 92991 => true,
      == 92997 => true,
      == 113820 => true,
      >= 118608 && <= 118723 => true,
      >= 118784 && <= 119029 => true,
      >= 119040 && <= 119078 => true,
      >= 119081 && <= 119140 => true,
      >= 119146 && <= 119148 => true,
      >= 119171 && <= 119172 => true,
      >= 119180 && <= 119209 => true,
      >= 119214 && <= 119274 => true,
      >= 119296 && <= 119361 => true,
      == 119365 => true,
      >= 119552 && <= 119638 => true,
      == 120513 => true,
      == 120539 => true,
      == 120571 => true,
      == 120597 => true,
      == 120629 => true,
      == 120655 => true,
      == 120687 => true,
      == 120713 => true,
      == 120745 => true,
      == 120771 => true,
      >= 120832 && <= 121343 => true,
      >= 121399 && <= 121402 => true,
      >= 121453 && <= 121460 => true,
      >= 121462 && <= 121475 => true,
      >= 121477 && <= 121478 => true,
      == 123215 => true,
      == 123647 => true,
      == 126124 => true,
      == 126128 => true,
      == 126254 => true,
      >= 126704 && <= 126705 => true,
      >= 126976 && <= 127019 => true,
      >= 127024 && <= 127123 => true,
      >= 127136 && <= 127150 => true,
      >= 127153 && <= 127167 => true,
      >= 127169 && <= 127183 => true,
      >= 127185 && <= 127221 => true,
      >= 127245 && <= 127405 => true,
      >= 127462 && <= 127490 => true,
      >= 127504 && <= 127547 => true,
      >= 127552 && <= 127560 => true,
      >= 127568 && <= 127569 => true,
      >= 127584 && <= 127589 => true,
      >= 127744 && <= 128727 => true,
      >= 128732 && <= 128748 => true,
      >= 128752 && <= 128764 => true,
      >= 128768 && <= 128886 => true,
      >= 128891 && <= 128985 => true,
      >= 128992 && <= 129003 => true,
      == 129008 => true,
      >= 129024 && <= 129035 => true,
      >= 129040 && <= 129095 => true,
      >= 129104 && <= 129113 => true,
      >= 129120 && <= 129159 => true,
      >= 129168 && <= 129197 => true,
      >= 129200 && <= 129201 => true,
      >= 129280 && <= 129619 => true,
      >= 129632 && <= 129645 => true,
      >= 129648 && <= 129660 => true,
      >= 129664 && <= 129672 => true,
      >= 129680 && <= 129725 => true,
      >= 129727 && <= 129733 => true,
      >= 129742 && <= 129755 => true,
      >= 129760 && <= 129768 => true,
      >= 129776 && <= 129784 => true,
      >= 129792 && <= 129938 => true,
      >= 129940 && <= 129994 => true,
      _ => false,
    };
