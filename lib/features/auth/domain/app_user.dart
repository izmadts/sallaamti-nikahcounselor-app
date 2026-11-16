// Mirrors App\Http\Resources\Api\UserResource on the backend.
class AppUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String avatarUrl;
  final List<String> roles;
  // 'nikah_counselor' | 'certified_nikah_counselor' | 'senior_nikah_counselor'
  // | 'regional_nikah_coordinator' — null only if the account somehow lacks
  // the matchmaker role, which shouldn't happen inside this app.
  final String? tier;
  // Trainee-access addendum (15/16 Nov 2026). null for a non-counselor
  // account; 'training'/'assessed'/'probation' for a matchmaker_trainee;
  // 'certified' for a full matchmaker. See MatchmakerStageAccess (backend).
  final String? ncStage;
  // Feature keys unlocked at ncStage — empty for a plain trainee at
  // Training, everything for 'certified'. Drives LockedFeatureGate and the
  // Browse bottom-nav destination.
  final List<String> ncFeatures;
  final int? ncLeadCap;

  AppUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.avatarUrl,
    required this.roles,
    this.tier,
    this.ncStage,
    this.ncFeatures = const [],
    this.ncLeadCap,
  });

  // 'matchmaker' meant "fully certified" before this addendum and still
  // does — nothing that already checked isMatchmaker specifically wants
  // trainee access too. Real app-entry gating uses hasAppAccess instead.
  bool get isMatchmaker => roles.contains('matchmaker');

  bool get hasAppAccess => roles.contains('matchmaker') || roles.contains('matchmaker_trainee');

  bool hasFeature(String key) => isMatchmaker || ncFeatures.contains(key);

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String? ?? '',
        roles: (json['roles'] as List? ?? []).map((e) => e.toString()).toList(),
        tier: json['tier'] as String?,
        ncStage: json['nc_stage'] as String?,
        ncFeatures: (json['nc_features'] as List? ?? []).map((e) => e.toString()).toList(),
        ncLeadCap: json['nc_lead_cap'] as int?,
      );

  // Round-trips through SecureStore so a restored session has something to
  // show immediately if the /auth/me call that would normally refresh it
  // fails for a reason that isn't "this token is invalid" (see
  // AuthController._restoreSession()).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'roles': roles,
        'tier': tier,
        'nc_stage': ncStage,
        'nc_features': ncFeatures,
        'nc_lead_cap': ncLeadCap,
      };
}
