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

  AppUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.avatarUrl,
    required this.roles,
    this.tier,
  });

  bool get isMatchmaker => roles.contains('matchmaker');

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String? ?? '',
        roles: (json['roles'] as List? ?? []).map((e) => e.toString()).toList(),
        tier: json['tier'] as String?,
      );
}
