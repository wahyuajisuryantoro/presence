part of 'get_user_bloc.dart';

@freezed
class GetUserEvent with _$GetUserEvent {
  const factory GetUserEvent.started() = _Started;
  const factory GetUserEvent.getUser() = _GetUser;
}