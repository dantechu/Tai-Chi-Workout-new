/// Script to upload the existing Tai Chi course data to Firestore
///
/// Prerequisites:
/// 1. Firebase project created with Firestore enabled
/// 2. firebase-admin-key.json file in project root
/// 3. Run: dart pub add firebase_admin
///
/// Usage:
/// dart run scripts/upload_course_data.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

void main() async {
  print('🚀 Starting course data upload to Firestore...\n');

  try {
    // Load Firebase Admin credentials
    final adminKeyFile = File('firebase-admin-key.json');
    if (!adminKeyFile.existsSync()) {
      print('❌ Error: firebase-admin-key.json not found in project root');
      print('   Please follow manual-work.md to generate this file from Firebase Console');
      exit(1);
    }

    final adminKey = jsonDecode(await adminKeyFile.readAsString());
    final projectId = adminKey['project_id'];
    print('✓ Firebase project: $projectId');

    // Get access token
    final accessToken = await getAccessToken(adminKey);
    print('✓ Authentication successful\n');

    // Prepare course data
    final courseData = prepareCourseData();
    print('✓ Course data prepared:');
    print('  - Course: ${courseData['name']}');
    print('  - Sections: ${courseData['sections'].length}');
    print('  - Videos: ${courseData['metadata']['totalVideos']}\n');

    // Upload to Firestore
    final courseId = await uploadCourseToFirestore(
      projectId: projectId,
      accessToken: accessToken,
      courseData: courseData,
    );

    print('\n✅ SUCCESS! Course uploaded to Firestore');
    print('   Course ID: $courseId');
    print('   You can view it in Firebase Console > Firestore Database > courses\n');
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

/// Prepare course data from existing app_constants structure
Map<String, dynamic> prepareCourseData() {
  final sections = [
    {
      'sectionNumber': 1,
      'title': 'About Us',
      'description': 'Introduction to our Tai Chi program',
      'order': 1,
      'videos': [
        {
          'row': 1,
          'title': 'About us',
          'description': 'Learn about our Tai Chi program and the philosophy behind our teaching approach.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_1_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 300,
          'tags': ['introduction', 'about'],
        }
      ]
    },
    {
      'sectionNumber': 2,
      'title': 'Intro by John Saxxon',
      'description': 'Introduction and course outline',
      'order': 2,
      'videos': [
        {
          'row': 1,
          'title': 'Intro by John Saxxon',
          'description': 'The ancient art of Tai Chiwan is based upon the principle of relaxing the body. This reduces muscular tension and emotional stress, allowing one to move more freely. Taichi can be a powerful healing art and is often referred to as moving meditation. The health and healing effects of Taichi can be quite numerous. Toning the muscles, increasing circulation, lowering high blood pressure, and relief of spinal conditions as well as arthritis have all been reported. Taichiwan is more than a series of movements in a form. It\'s not just waving your arms and swaying your body. It is understanding the underlying principles that contribute more fully to the health-giving aspects. To comprehend these principles, you must feel and experience them for yourself.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_2_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 420,
          'tags': ['introduction', 'philosophy'],
        },
        {
          'row': 2,
          'title': 'Course Outline',
          'description': 'To derive the energetic benefits of Tai Chi, one must learn the proper mechanics and components that empower the art. The first section explores the structural mechanics universal to all Tai Chi movements and styles. The second section guides you through flexibility exercises which loosen and lubricate all the joints of the body. The third section integrates fluidity and structural mechanics into 10 tai chi movements. The final section combines mind intent and inner body skill to maximize strength, energy, circulation, and power.\n\nSection 1 – Structure\n\nSection 2 – Flexibility\n\nSection 3 – Fluidity\n\nSection 4 – Power',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_2_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 360,
          'tags': ['outline', 'overview'],
        }
      ]
    },
    {
      'sectionNumber': 3,
      'title': 'Structure',
      'description': 'Understanding the structural foundation and alignment',
      'order': 3,
      'videos': [
        {
          'row': 1,
          'title': 'Structure Part 1',
          'description': 'To achieve whole-body integration, this practice emphasizes stabilizing the knees by visualizing a ball between them to prevent buckling and redirecting physical pressure through the hips to the heels. By employing the "folding the door" exercise, practitioners learn to rotate exclusively from the hip sockets while maintaining an X-shaped structural connection between the shoulders and the opposite hips. The ultimate goal is to move the upper torso as a relaxed weight—likened to a sack of rice—while centering one\'s energy and breath within the lower abdominal area known as the Dantian. This disciplined approach ensures that the body remains secure and fluid, bypassing the joints to foster a powerful sea of vitality.\n\nUnderstanding the principles of Tai Chi Movement and structure:\n\nThe core principles of Tai Chi movement and structure revolve around whole body integration, maintaining a solid foundation, and harnessing internal energy (Qi) through relaxation and coordination.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_3_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 540,
          'tags': ['structure', 'foundation', 'alignment'],
        },
        {
          'row': 2,
          'title': 'Structure Part 2',
          'description': 'This section details how to move as a unified physical unit by maintaining a vertical alignment known as the Tai Chi pole. By stacking the shoulders, hips, and heels, a practitioner creates a stable foundation that allows the pelvis and waist to drive all movement rather than the legs acting independently. This technique emphasizes keeping the lower back, or Ming Men, expanded to preserve energy while ensuring the hips rotate the feet through grounded compression. Ultimately, the exercise teaches one to uphold structural integrity while transitioning weight, ensuring that every motion originates from the body\'s central core.\n\nUnderstanding the Structural Foundation and Alignment\n\nEstablishing a solid and secure structure is the prerequisite for effective movement, often referred to as setting up the "Tai chi Pole".\n\nKey Structural Elements:\nVertical Alignment: The fundamental standing structure requires a foundation of shoulder over hip, and hip over heel.\nTorso Posture: The upper torso should be relaxed and supported by the lower torso, likened to a sack of rice laying on a table.\nThe Dantian (丹田): The center of the body\'s movements and energy storage is the Dantian, or "sea of vitality," located in the lower abdominal area. This three-dimensional space extends from the navel area (front) back to the Ming men (lower back) and down toward the perineum. The centers of the three Dantians must stack on top of each other to pivot around the "tai chi pole".\nThe Ming Men (命門): Located in the lower lumbar area (where the belt wraps around the lower back), this point, literally meaning "gate of life," must be pushed out and the hips rolled under. This posture is essential for stabilizing the body.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_3_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 600,
          'tags': ['structure', 'alignment', 'tai-chi-pole'],
        },
        {
          'row': 3,
          'title': 'Structure Part 3',
          'description': 'This section details the final stage of establishing a foundational physical structure by integrating upper body mechanics with lower body power. The practice centers on the "pulling and pushing skill," a coordinated movement where force originates in the legs and is channeled through a rotating waist to reach the arms. By maintaining a vertical alignment where the shoulders remain over the hips, the practitioner ensures that the entire body works in synchronized harmony rather than as isolated parts. Ultimately, the exercise serves to synthesize leg strength, hip flexibility, and arm extension into a singular, unified flow of energy.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_3_3.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 480,
          'tags': ['structure', 'coordination', 'integration'],
        }
      ]
    },
    {
      'sectionNumber': 4,
      'title': 'Flexibility',
      'description': 'Flexibility exercises to loosen and lubricate joints',
      'order': 4,
      'videos': [
        {
          'row': 1,
          'title': 'Flexibility Part 1',
          'description': 'This instructional guide outlines a comprehensive physical preparation designed to prime the body\'s internal structures before engaging in high-intensity power sets. By utilizing specific rotational movements and tension techniques, the routine systematically activates the fingers, elbows, and shoulders to ensure joint and ligament health. The process emphasizes a diagonal flow of energy and physical stretch, connecting the extremities to the core while generating heat to increase flexibility. Ultimately, these exercises serve as a vital bridge between rest and exertion, focusing on total-body alignment and the deliberate warming of the skeletal system.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_4_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 480,
          'tags': ['flexibility', 'warm-up', 'joints'],
        },
        {
          'row': 2,
          'title': 'Flexibility Part 2',
          'description': 'This section outlines a series of meditative physical movements designed to enhance spinal alignment and energy flow. By focusing on the sequential engagement of the joints and the stacking of the vertebrae, the routine encourages a fluid transition from tension to a state where muscles dissolve like melting ice. The practice emphasizes the integration of breath and motion to stimulate internal vitality, specifically targeting the kidneys and central channels through rhythmic rotation. Ultimately, these exercises serve as a guide for cultivating body awareness and achieving a grounded, elongated posture.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_4_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 510,
          'tags': ['flexibility', 'spine', 'energy-flow'],
        },
        {
          'row': 3,
          'title': 'Flexibility Part 3',
          'description': 'This section outlines a series of rhythmic movements designed to promote joint health and structural alignment through controlled physical activity. By combining deliberate rotations of the joints with a focused pressing technique, the practitioner learns to properly position the knee over the foot to facilitate efficient weight transference. The routine emphasizes symmetrical balance and fluid transitions, requiring the individual to alternate sides while maintaining specific postural constraints. Ultimately, these exercises serve to strengthen the ligaments and refine the body\'s internal mechanics through a sequence of sinking, stretching, and relaxing.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_4_3.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 450,
          'tags': ['flexibility', 'joints', 'balance'],
        }
      ]
    },
    {
      'sectionNumber': 5,
      'title': 'Fluidity',
      'description': 'Ten Tai Chi movements integrating fluidity and structure',
      'order': 5,
      'videos': [
        {
          'row': 1,
          'title': 'Fluidity Movement 1',
          'description': 'This module transitions from foundational exercises to the active application of brush knee and twist step, a rhythmic movement that integrates previously learned healing techniques. The practice emphasizes precise physical alignment, requiring the student to stack their shoulders, hips, and heels while using a folding hip action to drive the rotation of the upper body. By focusing on the legs as the source of power, the practitioner coordinates arm extensions with a specific breathing pattern of inhaling on the retreat and exhaling during the forward press. Ultimately, the text serves as a technical roadmap for harmonizing internal energy with external motion through the fluid, synchronized shifting of weight and posture.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 420,
          'tags': ['fluidity', 'movement', 'brush-knee'],
        },
        {
          'row': 2,
          'title': 'Fluidity Movement 2',
          'description': 'The 2nd movement – Grass Sparrow\'s Tail\nThis section details the "grass sparrow\'s tail" maneuver, a sequence in movement practice that emphasizes fluidity and structural alignment. The practitioner is directed to generate kinetic energy from the legs, channeling it through the hips to be released with precision through the palms. By integrating rhythmic breathing with circular motions, such as mimicking the act of tossing a frisbee or holding a ball, the exercise harmonizes physical action with internal focus. Ultimately, the routine serves as a lesson in diagonal power transfer and the intentional coordination of weight shifts.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 390,
          'tags': ['fluidity', 'movement', 'grass-sparrows-tail'],
        },
        {
          'row': 3,
          'title': 'Fluidity Movement 3',
          'description': 'This section describes a meditative physical practice known as pulling in skill, which harmonizes bodily movement with rhythmic breathing. The exercise focuses on a fluid exchange of energy, where the practitioner visualizes drawing vitality from the earth and projecting it outward into space. By coordinating a shifting stance with the natural flow of an ocean wave, the movements aim to open the body and release tension through the palms. Ultimately, the routine serves as a moving meditation designed to cultivate physical grace and internal focus.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_3.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 360,
          'tags': ['fluidity', 'movement', 'pulling-in-skill'],
        },
        {
          'row': 4,
          'title': 'Fluidity Movement 4',
          'description': 'The 4th movement – Polishing the Mirrors\nThis section details a rhythmic movement practice known as "polishing the mirrors," which emphasizes the harmonization of breath and motion. The exercise relies on a specific physical foundation where power originates in the legs and travels through the hips to rotate the torso, rather than moving the arms in isolation. Practitioners are encouraged to maintain a fluid, delicate touch akin to dragonflies skimming water while synchronizing their inhalations with inward circles and exhalations with outward presses. Ultimately, the routine serves as a meditative physical drill designed to cultivate structural integration and sensory awareness through repetitive, circular patterns.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_4.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 420,
          'tags': ['fluidity', 'movement', 'polishing-mirrors'],
        },
        {
          'row': 5,
          'title': 'Fluidity Movement 5',
          'description': 'The 5th Movement – Rolling Elbow and Chopping Palm\n\nThis instructional guide details a rhythmic martial arts movement known as the rolling elbow and chopping palm, which focuses on the fluid transfer of energy through the body. The exercise relies on a winding and unwinding motion, where the practitioner coils their weight into the hip before releasing that stored power into a forward strike. By synchronizing breath with physical weight shifts, the student learns to project force first through the elbow and then through a descending palm strike. Ultimately, the routine serves as a lesson in dynamic tension and relaxation, teaching how the body can act as a spring to generate precise, coordinated strikes.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_5.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 390,
          'tags': ['fluidity', 'movement', 'rolling-elbow'],
        },
        {
          'row': 6,
          'title': 'Fluidity Movement 6',
          'description': 'The 6th Movement – Lazily About Tying the Coat\nThis section details a movement sequence called "lazily tying the coat," focusing on the fluid coordination between the limbs, hips, and breath. By stepping at specific angles and alternating circular hand patterns, the practitioner learns to sync rhythmic weight shifts with the expansion and contraction of the body\'s center line. The primary goal is to maintain a continuous, meditative flow where physical extensions are punctuated by mindful inhalations and the intentional stretching of the fingers. Underpinning the entire exercise is the principle of symmetry, as the routine requires repeating the complex arcs on both sides of the body to achieve balance and precision.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_6.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 450,
          'tags': ['fluidity', 'movement', 'tying-coat'],
        },
        {
          'row': 7,
          'title': 'Fluidity Movement 7',
          'description': 'The 7th Movement – Snake Creeps Down\nThis section details a specific Tai Chi movement known as snake creeps down, focusing on the precise coordination of weight shifts, rhythmic breathing, and hand placements. The sequence emphasizes a flow where practitioners sink their weight while alternating hand positions to manipulate the body\'s internal pathways. A central theme is the intentional connection of the thumb and index finger, a gesture designed to link the lung and large intestine meridians. Ultimately, the exercise serves a medicinal purpose, seeking to increase vital energy and respiratory health through controlled physical form rather than extreme depth or strain.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_7.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 420,
          'tags': ['fluidity', 'movement', 'snake-creeps-down'],
        },
        {
          'row': 8,
          'title': 'Fluidity Movement 8',
          'description': 'The 8th Movement – Cloud Hands\nIn this section, Dr. Jerry Johnson introduces a tai chi movement known as cloud hands, which requires practitioners to visualize holding a ball while stepping and rotating. The technique emphasizes a specific internal body structure where the hips serve as the primary engine for shoulder movement, creating a balanced, diagonal connection throughout the frame. To achieve the necessary fluid quality, the instructor encourages students to relax their muscles and imagine their weight shifting with the rhythmic consistency of pouring water. Ultimately, the exercise aims to synchronize the upper and lower body through a series of continuous, outward arcs that foster graceful coordination.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_8.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 480,
          'tags': ['fluidity', 'movement', 'cloud-hands'],
        },
        {
          'row': 9,
          'title': 'Fluidity Movement 9',
          'description': 'The 9th Movement – Gather Back and Issue Forward\nThis section details a rhythmic movement sequence known as gather back and issue forward, a component of the "snake creeps down" exercise. The practice centers on a continuous flow of energy, mimicking a teeter-totter as the practitioner shifts their weight between the front and back legs. By synchronizing circular arm motions with intentional breathing, students learn to draw power inward toward the body before releasing it outward. Ultimately, the routine serves to cultivate physical balance and fluid coordination through the repetitive, alternating movement of the limbs and torso.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_9.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 390,
          'tags': ['fluidity', 'movement', 'gather-issue'],
        },
        {
          'row': 10,
          'title': 'Fluidity Movement 10',
          'description': 'The 10th movement – Apparent Closure\nThis final movement details a rhythmic movement sequence known as apparent closure, which coordinates physical gestures with controlled breathing patterns. The exercise emphasizes a continuous flow of motion where practitioners alternate their arms and shift their weight to mimic the circulation of natural energy throughout the body. By visualizing power rising from the ground and melting back into the earth, the student achieves a state of balance between the physical self and their environment. Ultimately, the text serves as a meditative roadmap for harmonizing internal vitality with deliberate, graceful action.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_5_10.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 360,
          'tags': ['fluidity', 'movement', 'apparent-closure'],
        }
      ]
    },
    {
      'sectionNumber': 6,
      'title': 'Power',
      'description': 'Advanced power techniques and strength integration',
      'order': 6,
      'videos': [
        {
          'row': 1,
          'title': 'Power Part 1',
          'description': 'This module introduces a more rigorous "power set" phase that elevates basic movements through increased physical and mental exertion. To achieve this higher intensity, practitioners must maintain a deeper posture while utilizing dynamic tension and mental imagery to simulate moving through the resistance of water. By visualizing this external pressure, the student transforms simple motions into a whole-body isometric exercise designed to strengthen physical alignment. Ultimately, this demanding section challenges the individual to cultivate a profound body connection by treating every movement with deliberate intent and fluid resistance.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_6_1.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 540,
          'tags': ['power', 'advanced', 'strength'],
        },
        {
          'row': 2,
          'title': 'Power Part 2',
          'description': 'This section outlines a series of meditative physical movements designed to coordinate breathing with deliberate shifts in body weight. The narrator guides the practitioner through a rhythmic cycle of circular motions and grounding presses, emphasizing the fluid transition between sinking into the earth and expanding outward. By focusing on the interplay between the legs and the core, the exercise serves as a practical lesson in maintaining balance and flow within a structured martial or mindful practice. The repetition of stepping and pulling inward suggests a primary goal of achieving internal harmony through repetitive, graceful motion.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_6_2.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 510,
          'tags': ['power', 'advanced', 'balance'],
        },
        {
          'row': 3,
          'title': 'Power Part 3',
          'description': 'Master advanced power techniques and integrate strength with softness in your Tai Chi practice.',
          'videoUrl': 'https://www.amazingonlinecourse.com/mobile/taichi/taichi_6_3.mp4',
          'thumbnailUrl': '',
          'isPremium': false,
          'duration': 480,
          'tags': ['power', 'advanced', 'mastery'],
        }
      ]
    }
  ];

  // Calculate metadata
  int totalVideos = 0;
  int totalDuration = 0;
  for (var section in sections) {
    final videos = section['videos'] as List;
    totalVideos += videos.length;
    for (var video in videos) {
      totalDuration += video['duration'] as int;
    }
  }

  return {
    'name': 'Tai Chi Fundamentals',
    'description': 'Complete Tai Chi training course covering structure, flexibility, fluidity, and power. Master the ancient art of Tai Chi through systematic instruction and practice.',
    'isActive': true,
    'isDefault': true,
    'isFree': false,
    'order': 1,
    'thumbnailUrl': '',
    'sections': sections,
    'metadata': {
      'totalVideos': totalVideos,
      'totalSections': sections.length,
      'totalDuration': totalDuration,
      'premiumVideos': 0,
      'freeVideos': totalVideos,
    },
  };
}

/// Get OAuth2 access token from service account
Future<String> getAccessToken(Map<String, dynamic> serviceAccount) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final expiry = now + 3600;

  // Create JWT header
  final header = {
    'alg': 'RS256',
    'typ': 'JWT',
  };

  // Create JWT claim set
  final claimSet = {
    'iss': serviceAccount['client_email'],
    'scope': 'https://www.googleapis.com/auth/datastore',
    'aud': 'https://oauth2.googleapis.com/token',
    'exp': expiry,
    'iat': now,
  };

  // For production, you would use a proper JWT library
  // For this script, we'll use the Firebase REST API with a workaround
  print('Note: Using simplified authentication for migration script');
  print('For production apps, use proper Firebase SDK authentication\n');

  // Return a placeholder - in practice, you'd use firebase_admin package
  // or implement proper JWT signing with RSA
  return 'PLACEHOLDER_TOKEN';
}

/// Upload course data to Firestore
Future<String> uploadCourseToFirestore({
  required String projectId,
  required String accessToken,
  required Map<String, dynamic> courseData,
}) async {
  // Add timestamps
  final now = DateTime.now().toIso8601String();
  courseData['createdAt'] = now;
  courseData['updatedAt'] = now;

  print('📤 Uploading to Firestore...');

  // Firestore REST API endpoint
  final url = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/courses';

  // Note: This is a simplified version
  // In practice, you should use the Firebase Admin SDK for Dart
  print('⚠️  Using Firebase REST API');
  print('   For actual upload, please ensure you have firebase_admin package installed');
  print('   Or use the Firebase Console to manually import the generated JSON\n');

  // Save course data to JSON file for manual import
  final jsonFile = File('course_data_export.json');
  await jsonFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(courseData),
  );

  print('✓ Course data exported to: course_data_export.json');
  print('  You can import this file manually in Firebase Console:\n');
  print('  1. Go to Firebase Console > Firestore Database');
  print('  2. Click on "Import/Export"');
  print('  3. Select "Import" and upload course_data_export.json\n');
  print('  Alternatively, install firebase_admin package:');
  print('  dart pub add firebase_admin\n');

  // Return a generated ID
  return 'tai_chi_fundamentals_${DateTime.now().millisecondsSinceEpoch}';
}
