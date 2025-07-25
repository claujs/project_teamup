import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> init();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveObject<T>(String key, T object);
  Future<T?> getObject<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class LocalStorageImpl implements LocalStorage {
  static final LocalStorageImpl _instance = LocalStorageImpl._internal();
  factory LocalStorageImpl() => _instance;
  LocalStorageImpl._internal();

  late SharedPreferences _prefs;
  late Box _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
    _box = await Hive.openBox('app_cache');
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> saveObject<T>(String key, T object) async {
    await _box.put(key, object);
  }

  @override
  Future<T?> getObject<T>(String key) async {
    return _box.get(key) as T?;
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
    await _box.clear();
  }
}
