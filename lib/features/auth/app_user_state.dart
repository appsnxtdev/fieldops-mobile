import 'package:flutter/foundation.dart';

import 'tenant_repository.dart';
import 'user_repository.dart';

class AppUserState extends ChangeNotifier {
  AppUserState({UserRepository? userRepo, TenantRepository? tenantRepo})
      : _userRepo = userRepo ?? UserRepository(),
        _tenantRepo = tenantRepo ?? TenantRepository();

  final UserRepository _userRepo;
  final TenantRepository _tenantRepo;

  UserProfile? _user;
  Tenant? _tenant;
  bool _loaded = false;
  String? _error;

  UserProfile? get user => _user;
  Tenant? get tenant => _tenant;
  bool get loaded => _loaded;
  String? get error => _error;

  Future<void> load() async {
    _error = null;
    try {
      final results = await Future.wait([_userRepo.getMe(), _tenantRepo.getMyTenant()]);
      _user = results[0] as UserProfile;
      _tenant = results[1] as Tenant;
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void clear() {
    _user = null;
    _tenant = null;
    _loaded = false;
    _error = null;
    notifyListeners();
  }
}
