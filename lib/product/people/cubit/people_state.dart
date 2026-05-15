part of 'people_cubit.dart';

enum PeopleStatus { initial, loading, success, error }

class PeopleState {
  final PeopleStatus status;
  final List<OrgUserModel> users;
  final List<OrgUserModel> allUsers;
  final String query;
  final bool creatingDm;
  final String? errorMessage;

  const PeopleState({
    this.status = PeopleStatus.initial,
    this.users = const [],
    this.allUsers = const [],
    this.query = '',
    this.creatingDm = false,
    this.errorMessage,
  });

  PeopleState copyWith({
    PeopleStatus? status,
    List<OrgUserModel>? users,
    List<OrgUserModel>? allUsers,
    String? query,
    bool? creatingDm,
    String? errorMessage,
  }) =>
      PeopleState(
        status: status ?? this.status,
        users: users ?? this.users,
        allUsers: allUsers ?? this.allUsers,
        query: query ?? this.query,
        creatingDm: creatingDm ?? this.creatingDm,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
