class ApiConstants {
  static const String baseUrl = 'https://www.amazingonlinecourse.com/mobile/taichi/';
  
  static String getVideoUrl(int section, int row) {
    return '${baseUrl}taichi_${section}_$row.mp4';
  }
  
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}