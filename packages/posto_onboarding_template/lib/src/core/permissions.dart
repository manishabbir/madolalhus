enum PermissionAction { view, create, edit, delete }

class PermissionPolicy {
  final List<String> roles;
  final List<PermissionAction> actions;

  const PermissionPolicy({
    required this.roles,
    required this.actions,
  });
}

class Permissions {
  static bool can(PermissionPolicy policy, String role, PermissionAction action) {
    return policy.roles.contains(role) && policy.actions.contains(action);
  }

  static PermissionPolicy adminAll() {
    return const PermissionPolicy(
      roles: ['admin'],
      actions: [
        PermissionAction.view,
        PermissionAction.create,
        PermissionAction.edit,
        PermissionAction.delete,
      ],
    );
  }

  static PermissionPolicy managerOperational() {
    return const PermissionPolicy(
      roles: ['admin', 'manager'],
      actions: [
        PermissionAction.view,
        PermissionAction.create,
        PermissionAction.edit,
      ],
    );
  }
}
