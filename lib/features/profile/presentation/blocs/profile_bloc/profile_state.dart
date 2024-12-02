import 'package:equatable/equatable.dart';
import 'package:blink/features/user/domain/entities/user_entity.dart';
import 'package:blink/features/video/data/models/video_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<VideoModel> videos;

  const ProfileLoaded({
    required this.user,
    required this.videos,
  });

  @override
  List<Object?> get props => [user, videos];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
