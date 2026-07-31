/// SafeRide is single-tenant-per-school by design (an admin only ever sees
/// their own school's data — see the spec). Managing *multiple* schools
/// (creating new ones, provisioning each school's first admin) needs an
/// identity above that, but the spec doesn't define one and there's no
/// backend to issue a proper role/claim for it on the Spark plan.
///
/// So super admin status is decided purely by matching the signed-in user's
/// verified email — no Firestore doc required. This mirrors how the same
/// check is expressed in `firestore.rules` via `request.auth.token.email`.
class SuperAdminConfig {
  const SuperAdminConfig._();

  static const String email = 'ngabirediane02@gmail.com';

  static bool isSuperAdmin(String? userEmail) {
    if (userEmail == null) return false;
    return userEmail.toLowerCase() == email.toLowerCase();
  }
}
