class AppConstants {
  static const String appName = 'Tai Chi Workout';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.amazingelearning.chikung';
  
  // Contact Information
  static const String supportEmail = 'support@stepbysteplearn.com';
  static const String supportPhone = '1(650)692-2500';
  static const String website = 'stepbysteplearn.com';

  // URLs
  static const String privacyPolicyUrl = 'https://amazingelearning.com/privacy-policy/';
  static const String termsOfServiceUrl = 'https://amazingelearning.com/terms';
  
  // Premium
  static const String premiumProductId = 'com.amazingelearning.chikung.Premium';
  static const String premiumPrice = '\$4.99';
  
  // Storage Keys
  static const String hiveVideoBox = 'videos_box';
  static const String hiveDownloadBox = 'downloads_box';
  static const String hivePremiumBox = 'premium_box';
  static const String hiveSettingsBox = 'settings_box';
  static const String hiveFavoritesBox = 'favorites_box';
  static const String hiveCoursesBox = 'courses_box';
  
  // Secure Storage Keys
  static const String premiumTokenKey = 'premium_token';
  static const String userIdKey = 'user_id';
  
  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingKey = 'onboarding_complete';
  static const String selectedCourseKey = 'selected_course_id';
  
  // Video Categories
  static const List<Map<String, dynamic>> videoCategories = [
    {
      'section': 1,
      'title': 'About Us',
      'videos': [
        {
          'row': 1,
          'title': 'About us',
          'isPremium': false,
          'description': 'Learn about our Tai Chi program and the philosophy behind our teaching approach.'
        }
      ]
    },
    {
      'section': 2,
      'title': 'Intro by Dr Jerry Johnson',
      'videos': [
        {
          'row': 1,
          'title': 'Intro by Dr Jerry Johnson',
          'isPremium': false,
          'description': 'The ancient art of Tai Chiwan is based upon the principle of relaxing the body. This reduces muscular tension and emotional stress, allowing one to move more freely. Taichi can be a powerful healing art and is often referred to as moving meditation. The health and healing effects of Taichi can be quite numerous. Toning the muscles, increasing circulation, lowering high blood pressure, and relief of spinal conditions as well as arthritis have all been reported. Taichiwan is more than a series of movements in a form. It’s not just waving your arms and swaying your body. It is understanding the underlying principles that contribute more fully to the health-giving aspects. To comprehend these principles, you must feel and experience them for yourself.'
        },
        {
          'row': 2,
          'title': 'Course Outline',
          'isPremium': false,
          'description': 'To derive the energetic benefits of Tai Chi, one must learn the proper mechanics and components that empower the art. The first section explores the structural mechanics universal to all Tai Chi movements and styles. The second section guides you through flexibility exercises which loosen and lubricate all the joints of the body. The third section integrates fluidity and structural mechanics into 10 tai chi movements. The final section combines mind intent and inner body skill to maximize strength, energy, circulation, and power.\n\nSection 1 – Structure\n\nSection 2 – Flexibility\n\nSection 3 – Fluidity\n\nSection 4 – Power'
        }
      ]
    },
    {
      'section': 3,
      'title': 'Structure',
      'videos': [
        {
          'row': 1,
          'title': 'Structure Part 1',
          'isPremium': false,
          'description': 'To achieve whole-body integration, this practice emphasizes stabilizing the knees by visualizing a ball between them to prevent buckling and redirecting physical pressure through the hips to the heels. By employing the "folding the door" exercise, practitioners learn to rotate exclusively from the hip sockets while maintaining an X-shaped structural connection between the shoulders and the opposite hips. The ultimate goal is to move the upper torso as a relaxed weight—likened to a sack of rice—while centering one\'s energy and breath within the lower abdominal area known as the Dantian. This disciplined approach ensures that the body remains secure and fluid, bypassing the joints to foster a powerful sea of vitality.\n\nUnderstanding the principles of Tai Chi Movement and structure:\n\nThe core principles of Tai Chi movement and structure revolve around whole body integration, maintaining a solid foundation, and harnessing internal energy (Qi) through relaxation and coordination.'
        },
        {
          'row': 2,
          'title': 'Structure Part 2',
          'isPremium': false,
          'description': 'This section details how to move as a unified physical unit by maintaining a vertical alignment known as the Tai Chi pole. By stacking the shoulders, hips, and heels, a practitioner creates a stable foundation that allows the pelvis and waist to drive all movement rather than the legs acting independently. This technique emphasizes keeping the lower back, or Ming Men, expanded to preserve energy while ensuring the hips rotate the feet through grounded compression. Ultimately, the exercise teaches one to uphold structural integrity while transitioning weight, ensuring that every motion originates from the body\'s central core.\n\nUnderstanding the Structural Foundation and Alignment\n\nEstablishing a solid and secure structure is the prerequisite for effective movement, often referred to as setting up the "Tai chi Pole".\n\nKey Structural Elements:\nVertical Alignment: The fundamental standing structure requires a foundation of shoulder over hip, and hip over heel.\nTorso Posture: The upper torso should be relaxed and supported by the lower torso, likened to a sack of rice laying on a table.\nThe Dantian (丹田): The center of the body\'s movements and energy storage is the Dantian, or "sea of vitality," located in the lower abdominal area. This three-dimensional space extends from the navel area (front) back to the Ming men (lower back) and down toward the perineum. The centers of the three Dantians must stack on top of each other to pivot around the "tai chi pole".\nThe Ming Men (命門): Located in the lower lumbar area (where the belt wraps around the lower back), this point, literally meaning "gate of life," must be pushed out and the hips rolled under. This posture is essential for stabilizing the body.'
        },
        {
          'row': 3,
          'title': 'Structure Part 3',
          'isPremium': false,
          'description': 'This section details the final stage of establishing a foundational physical structure by integrating upper body mechanics with lower body power. The practice centers on the "pulling and pushing skill," a coordinated movement where force originates in the legs and is channeled through a rotating waist to reach the arms. By maintaining a vertical alignment where the shoulders remain over the hips, the practitioner ensures that the entire body works in synchronized harmony rather than as isolated parts. Ultimately, the exercise serves to synthesize leg strength, hip flexibility, and arm extension into a singular, unified flow of energy.'
        }
      ]
    },
    {
      'section': 4,
      'title': 'Flexibility',
      'videos': [
        {
          'row': 1,
          'title': 'Flexibility Part 1',
          'isPremium': false,
          'description': 'This instructional guide outlines a comprehensive physical preparation designed to prime the body\'s internal structures before engaging in high-intensity power sets. By utilizing specific rotational movements and tension techniques, the routine systematically activates the fingers, elbows, and shoulders to ensure joint and ligament health. The process emphasizes a diagonal flow of energy and physical stretch, connecting the extremities to the core while generating heat to increase flexibility. Ultimately, these exercises serve as a vital bridge between rest and exertion, focusing on total-body alignment and the deliberate warming of the skeletal system.'
        },
        {
          'row': 2,
          'title': 'Flexibility Part 2',
          'isPremium': false,
          'description': 'This section outlines a series of meditative physical movements designed to enhance spinal alignment and energy flow. By focusing on the sequential engagement of the joints and the stacking of the vertebrae, the routine encourages a fluid transition from tension to a state where muscles dissolve like melting ice. The practice emphasizes the integration of breath and motion to stimulate internal vitality, specifically targeting the kidneys and central channels through rhythmic rotation. Ultimately, these exercises serve as a guide for cultivating body awareness and achieving a grounded, elongated posture.'
        },
        {
          'row': 3,
          'title': 'Flexibility Part 3',
          'isPremium': false,
          'description': 'This section outlines a series of rhythmic movements designed to promote joint health and structural alignment through controlled physical activity. By combining deliberate rotations of the joints with a focused pressing technique, the practitioner learns to properly position the knee over the foot to facilitate efficient weight transference. The routine emphasizes symmetrical balance and fluid transitions, requiring the individual to alternate sides while maintaining specific postural constraints. Ultimately, these exercises serve to strengthen the ligaments and refine the body\'s internal mechanics through a sequence of sinking, stretching, and relaxing.'
        }
      ]
    },
    {
      'section': 5,
      'title': 'Fluidity',
      'videos': [
        {
          'row': 1,
          'title': 'Fluidity Movement 1',
          'isPremium': false,
          'description': 'This module transitions from foundational exercises to the active application of brush knee and twist step, a rhythmic movement that integrates previously learned healing techniques. The practice emphasizes precise physical alignment, requiring the student to stack their shoulders, hips, and heels while using a folding hip action to drive the rotation of the upper body. By focusing on the legs as the source of power, the practitioner coordinates arm extensions with a specific breathing pattern of inhaling on the retreat and exhaling during the forward press. Ultimately, the text serves as a technical roadmap for harmonizing internal energy with external motion through the fluid, synchronized shifting of weight and posture.'
        },
        {
          'row': 2,
          'title': 'Fluidity Movement 2',
          'isPremium': false,
          'description': 'The 2nd movement – Grass Sparrow\'s Tail\nThis section details the "grass sparrow\'s tail" maneuver, a sequence in movement practice that emphasizes fluidity and structural alignment. The practitioner is directed to generate kinetic energy from the legs, channeling it through the hips to be released with precision through the palms. By integrating rhythmic breathing with circular motions, such as mimicking the act of tossing a frisbee or holding a ball, the exercise harmonizes physical action with internal focus. Ultimately, the routine serves as a lesson in diagonal power transfer and the intentional coordination of weight shifts.'
        },
        {
          'row': 3,
          'title': 'Fluidity Movement 3',
          'isPremium': false,
          'description': 'This section describes a meditative physical practice known as pulling in skill, which harmonizes bodily movement with rhythmic breathing. The exercise focuses on a fluid exchange of energy, where the practitioner visualizes drawing vitality from the earth and projecting it outward into space. By coordinating a shifting stance with the natural flow of an ocean wave, the movements aim to open the body and release tension through the palms. Ultimately, the routine serves as a moving meditation designed to cultivate physical grace and internal focus.'
        },
        {
          'row': 4,
          'title': 'Fluidity Movement 4',
          'isPremium': false,
          'description': 'The 4th movement – Polishing the Mirrors\nThis section details a rhythmic movement practice known as "polishing the mirrors," which emphasizes the harmonization of breath and motion. The exercise relies on a specific physical foundation where power originates in the legs and travels through the hips to rotate the torso, rather than moving the arms in isolation. Practitioners are encouraged to maintain a fluid, delicate touch akin to dragonflies skimming water while synchronizing their inhalations with inward circles and exhalations with outward presses. Ultimately, the routine serves as a meditative physical drill designed to cultivate structural integration and sensory awareness through repetitive, circular patterns.'
        },
        {
          'row': 5,
          'title': 'Fluidity Movement 5',
          'isPremium': false,
          'description': 'The 5th Movement – Rolling Elbow and Chopping Palm\n\nThis instructional guide details a rhythmic martial arts movement known as the rolling elbow and chopping palm, which focuses on the fluid transfer of energy through the body. The exercise relies on a winding and unwinding motion, where the practitioner coils their weight into the hip before releasing that stored power into a forward strike. By synchronizing breath with physical weight shifts, the student learns to project force first through the elbow and then through a descending palm strike. Ultimately, the routine serves as a lesson in dynamic tension and relaxation, teaching how the body can act as a spring to generate precise, coordinated strikes.'
        },
        {
          'row': 6,
          'title': 'Fluidity Movement 6',
          'isPremium': false,
          'description': 'The 6th Movement – Lazily About Tying the Coat\nThis section details a movement sequence called "lazily tying the coat," focusing on the fluid coordination between the limbs, hips, and breath. By stepping at specific angles and alternating circular hand patterns, the practitioner learns to sync rhythmic weight shifts with the expansion and contraction of the body\'s center line. The primary goal is to maintain a continuous, meditative flow where physical extensions are punctuated by mindful inhalations and the intentional stretching of the fingers. Underpinning the entire exercise is the principle of symmetry, as the routine requires repeating the complex arcs on both sides of the body to achieve balance and precision.'
        },
        {
          'row': 7,
          'title': 'Fluidity Movement 7',
          'isPremium': false,
          'description': 'The 7th Movement – Snake Creeps Down\nThis section details a specific Tai Chi movement known as snake creeps down, focusing on the precise coordination of weight shifts, rhythmic breathing, and hand placements. The sequence emphasizes a flow where practitioners sink their weight while alternating hand positions to manipulate the body\'s internal pathways. A central theme is the intentional connection of the thumb and index finger, a gesture designed to link the lung and large intestine meridians. Ultimately, the exercise serves a medicinal purpose, seeking to increase vital energy and respiratory health through controlled physical form rather than extreme depth or strain.'
        },
        {
          'row': 8,
          'title': 'Fluidity Movement 8',
          'isPremium': false,
          'description': 'The 8th Movement – Cloud Hands\nIn this section, Dr. Jerry Johnson introduces a tai chi movement known as cloud hands, which requires practitioners to visualize holding a ball while stepping and rotating. The technique emphasizes a specific internal body structure where the hips serve as the primary engine for shoulder movement, creating a balanced, diagonal connection throughout the frame. To achieve the necessary fluid quality, the instructor encourages students to relax their muscles and imagine their weight shifting with the rhythmic consistency of pouring water. Ultimately, the exercise aims to synchronize the upper and lower body through a series of continuous, outward arcs that foster graceful coordination.'
        },
        {
          'row': 9,
          'title': 'Fluidity Movement 9',
          'isPremium': false,
          'description': 'The 9th Movement – Gather Back and Issue Forward\nThis section details a rhythmic movement sequence known as gather back and issue forward, a component of the "snake creeps down" exercise. The practice centers on a continuous flow of energy, mimicking a teeter-totter as the practitioner shifts their weight between the front and back legs. By synchronizing circular arm motions with intentional breathing, students learn to draw power inward toward the body before releasing it outward. Ultimately, the routine serves to cultivate physical balance and fluid coordination through the repetitive, alternating movement of the limbs and torso.'
        },
        {
          'row': 10,
          'title': 'Fluidity Movement 10',
          'isPremium': false,
          'description': 'The 10th movement – Apparent Closure\nThis final movement details a rhythmic movement sequence known as apparent closure, which coordinates physical gestures with controlled breathing patterns. The exercise emphasizes a continuous flow of motion where practitioners alternate their arms and shift their weight to mimic the circulation of natural energy throughout the body. By visualizing power rising from the ground and melting back into the earth, the student achieves a state of balance between the physical self and their environment. Ultimately, the text serves as a meditative roadmap for harmonizing internal vitality with deliberate, graceful action.'
        }
      ]
    },
    {
      'section': 6,
      'title': 'Power',
      'videos': [
        {
          'row': 1,
          'title': 'Power Part 1',
          'isPremium': false,
          'description': 'This module introduces a more rigorous "power set" phase that elevates basic movements through increased physical and mental exertion. To achieve this higher intensity, practitioners must maintain a deeper posture while utilizing dynamic tension and mental imagery to simulate moving through the resistance of water. By visualizing this external pressure, the student transforms simple motions into a whole-body isometric exercise designed to strengthen physical alignment. Ultimately, this demanding section challenges the individual to cultivate a profound body connection by treating every movement with deliberate intent and fluid resistance.'
        },
        {
          'row': 2,
          'title': 'Power Part 2',
          'isPremium': false,
          'description': 'This section outlines a series of meditative physical movements designed to coordinate breathing with deliberate shifts in body weight. The narrator guides the practitioner through a rhythmic cycle of circular motions and grounding presses, emphasizing the fluid transition between sinking into the earth and expanding outward. By focusing on the interplay between the legs and the core, the exercise serves as a practical lesson in maintaining balance and flow within a structured martial or mindful practice. The repetition of stepping and pulling inward suggests a primary goal of achieving internal harmony through repetitive, graceful motion.'
        },
        {
          'row': 3,
          'title': 'Power Part 3',
          'isPremium': false,
          'description': 'Master advanced power techniques and integrate strength with softness in your Tai Chi practice.'
        }
      ]
    }
  ];
  
  // Audio Tracks
  static const List<Map<String, dynamic>> musicTracks = [
    {
      'id': 'tai_chi_calm',
      'title': 'Tai Chi Calm',
      'file': 'assets/audio/music/tai_chi_calm.mp3',
      'duration': Duration(minutes: 10),
    },
    {
      'id': 'meditation_flow',
      'title': 'Meditation Flow',
      'file': 'assets/audio/music/meditation_flow.mp3',
      'duration': Duration(minutes: 15),
    },
    {
      'id': 'peaceful_chi',
      'title': 'Peaceful Chi',
      'file': 'assets/audio/music/peaceful_chi.mp3',
      'duration': Duration(minutes: 12),
    },
  ];
  
  // Supported Locales
  static const List<Map<String, dynamic>> supportedLocales = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'zh', 'name': '简体中文', 'flag': '🇨🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];
}