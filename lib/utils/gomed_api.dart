class Bbapi {
  static const String baseUrl = "http://97.74.93.26:3000";
  static const String login = "$baseUrl/user/login";
  //static const String login1 = "$baseUrl/distributor/distributor/login";
  //static const String signup = "$baseUrl/user/signup";
  static const String deleteAccount = "$baseUrl/user/deleteProfile";
  static const String refreshToken="$baseUrl/auth/refresh-token";
  static const String updateProfile = "$baseUrl/user/updateProfile";
  //static const String getProducts = "$baseUrl/products/getallproducts";
  static const String getservices ="$baseUrl/services/getallservices";
  static const String createbooking ="$baseUrl/productbooking/Create";
  static const String servicebooking ="$baseUrl/servicebooking/create";
  static const String getproductbooking ="$baseUrl/productbooking/list";
  static const String updateproductbooking ="$baseUrl/productbooking/update";
  static const String cancelbooking ="$baseUrl/productbooking/delete";
  static const String getBookedServices ="$baseUrl/servicebooking/list";
  static const String cancelbookedservices ="$baseUrl/servicebooking/delete";
  static const String getProducts = "$baseUrl/products/products/approved";
  static const String getProductservices = "$baseUrl/products/adminAddProducts";
  static const String getServiceengineers = "$baseUrl/admin/service-engineers";
}                                                 