class ApiConst{
  ApiConst._();
  static ApiConst apiConst = ApiConst._();

  static const baseUrl = "https://agsdemo.in/3CBSapi/public/api/";
  static const login = "${baseUrl}login";
  static const recentTrip = "${baseUrl}fetch-recent-trip";
  static const fetchProfile = "${baseUrl}fetch-profile";
  static const tripHistory = "${baseUrl}fetch-trip-history";
  static const fetchSites = "${baseUrl}fetch-active-sites";
  static const createTrip = "${baseUrl}create-trip";
  static const updateProfile = "${baseUrl}update-profile";
  static const createSite = "${baseUrl}create-site";
  static const changePassword = "${baseUrl}change-password";
  static const deleteProfile = "${baseUrl}delete-profile";
  static const forgotPassword = "${baseUrl}forgot-password";

}