import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

final List<UserModel> _seedUsers = [
  UserModel(
    userId: 'user-admin-1',
    name: 'Michael Chen',
    email: 'michael.chen@schoolbus.com',
    phone: '(555) 456-7890',
    role: UserRole.admin,
    createdAt: DateTime(2024, 1, 10),
  ),
  UserModel(
    userId: 'user-driver-12',
    name: 'John Smith',
    email: 'john.smith@schoolbus.com',
    phone: '(555) 111-2222',
    role: UserRole.driver,
    createdAt: DateTime(2024, 2, 3),
  ),
  UserModel(
    userId: 'user-driver-07',
    name: 'Sarah Johnson',
    email: 'sarah.johnson@schoolbus.com',
    phone: '(555) 222-3333',
    role: UserRole.driver,
    createdAt: DateTime(2024, 2, 10),
  ),
  UserModel(
    userId: 'user-driver-15',
    name: 'Mike Davis',
    email: 'mike.davis@schoolbus.com',
    phone: '(555) 333-4444',
    role: UserRole.driver,
    createdAt: DateTime(2024, 3, 1),
  ),
  UserModel(
    userId: 'user-driver-03',
    name: 'Emily Brown',
    email: 'emily.brown@schoolbus.com',
    phone: '(555) 444-5555',
    role: UserRole.driver,
    createdAt: DateTime(2024, 3, 15),
  ),
  UserModel(
    userId: 'user-parent-1',
    name: 'Laura Martinez',
    email: 'laura.martinez@example.com',
    phone: '(555) 555-1010',
    role: UserRole.parent,
    createdAt: DateTime(2024, 1, 20),
  ),
  UserModel(
    userId: 'user-parent-2',
    name: 'David Kim',
    email: 'david.kim@example.com',
    phone: '(555) 555-2020',
    role: UserRole.parent,
    createdAt: DateTime(2024, 1, 22),
  ),
  UserModel(
    userId: 'user-parent-3',
    name: 'Priya Patel',
    email: 'priya.patel@example.com',
    phone: '(555) 555-3030',
    role: UserRole.parent,
    createdAt: DateTime(2024, 2, 1),
  ),
];

final usersProvider = Provider<List<UserModel>>((ref) => _seedUsers);

final currentAdminProvider = Provider<UserModel>((ref) {
  return ref.watch(usersProvider).firstWhere((u) => u.role == UserRole.admin);
});
