import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  // 用于存储已获取的地址缓存，Key 为 "经度,纬度"
  static final Map<String, String> _addressCache = {};

  /// 获取详细地址信息
  /// [longitude] 经度
  /// [latitude] 纬度
  /// [amapKey] 高德 Web 服务 Key
  static Future<String> getAddress(double longitude, double latitude, String amapKey) async {
    if (longitude == 0 && latitude == 0) return 'NO_LOCATION_INFO';
    if (amapKey.isEmpty) return 'PARSE_ADDRESS_FAILED: No API Key provided';

    // 格式化经纬度，保留 5 位小数（约 1.1 米精度），减少微小偏差导致的重复请求
    final String cacheKey =
        '${longitude.toStringAsFixed(5)},${latitude.toStringAsFixed(5)}';

    // 检查缓存
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://restapi.amap.com/v3/geocode/regeo?output=json&location=${longitude.toStringAsFixed(6)},${latitude.toStringAsFixed(6)}&key=$amapKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['regeocode'] != null) {
          final addressComponent = data['regeocode']['addressComponent'];

          // 辅助函数：安全地提取字符串字段，因为高德 API 在字段为空时可能返回空列表 []
          String safeString(dynamic value) {
            if (value is String) return value;
            if (value is List && value.isEmpty) return '';
            return '';
          }

          // 提取详细位置信息
          final country = safeString(addressComponent['country']);
          final province = safeString(addressComponent['province']);
          final cityValue = addressComponent['city'];
          final city = cityValue is String ? cityValue : '';
          final district = safeString(addressComponent['district']);
          final township = safeString(addressComponent['township']);
          
          // neighborhood 可能是一个 Map 或 List
          String neighborhoodName = '';
          final neighborhood = addressComponent['neighborhood'];
          if (neighborhood is Map) {
            neighborhoodName = safeString(neighborhood['name']);
          }

          // 格式化地址
          List<String> parts = [];
          if (country.isNotEmpty && country != '中国') parts.add(country);
          if (province.isNotEmpty) parts.add(province);
          if (city.isNotEmpty && city != province) parts.add(city);
          if (district.isNotEmpty) parts.add(district);
          if (township.isNotEmpty) parts.add(township);
          if (neighborhoodName.isNotEmpty) parts.add(neighborhoodName);

          String result;
          if (parts.isEmpty) {
            result = safeString(data['regeocode']['formatted_address']);
            if (result.isEmpty) result = 'UNKNOWN_LOCATION';
          } else {
            result = parts.join('');
          }

          // 存入缓存
          _addressCache[cacheKey] = result;
          return result;
        } else {
          final info = data['info'] as String? ?? 'UNKNOWN_ERROR';
          final infocode = data['infocode'] as String? ?? '';
          
          // 处理配额相关错误
          if (infocode == '10003' || infocode == '10004' || infocode == '10020') {
            return 'QUOTA_EXCEEDED: $info';
          }
          
          if (info == 'USERKEY_PLAT_NOMATCH' || infocode == '10009') {
            return 'PARSE_ADDRESS_FAILED: Key type mismatch. Please ensure you are using a "Web Service" key and have "Reverse Geocoding" permission enabled.';
          }
          return 'PARSE_ADDRESS_FAILED: $info ($infocode)';
        }
      }
      return 'NETWORK_REQUEST_FAILED (HTTP ${response.statusCode})';
    } catch (e) {
      // 详细记录错误以便排查
      print('LocationService Error: $e');
      if (e.toString().contains('SocketException')) {
        return 'NETWORK_CONNECTION_FAILED: Please check your internet connection and permissions.';
      }
      return 'ERROR: ${e.toString()}';
    }
  }
}
