import 'package:equatable/equatable.dart';

enum InspectionMode { pickup, returnMode }

class InspectionState extends Equatable {
  final InspectionMode mode;
  final int currentStep; // 0..5
  final bool isRecording;
  final bool isCompleted;
  final bool cameraReady;
  final String? error;

  const InspectionState({
    this.mode = InspectionMode.pickup,
    this.currentStep = 0,
    this.isRecording = false,
    this.isCompleted = false,
    this.cameraReady = false,
    this.error,
  });

  static const stepLabels = [
    'Filmez l\'avant du véhicule',
    'Filmez l\'arrière du véhicule',
    'Filmez le côté gauche',
    'Filmez le côté droit',
    'Filmez l\'intérieur (km + dashboard)',
  ];

  /// Guide image URL for each step (real car photos from Unsplash).
  static const stepGuideImages = [
    // Front view
    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&h=400&fit=crop',
    // Rear view
    'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=600&h=400&fit=crop',
    // Left side profile
    'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600&h=400&fit=crop',
    // Right side profile
    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600&h=400&fit=crop',
    // Interior + dashboard
    'https://images.unsplash.com/photo-1542362567-b07e54358753?w=600&h=400&fit=crop',
  ];

  /// Short angle name for caption
  static const stepAngles = [
    'AVANT',
    'ARRIÈRE',
    'CÔTÉ GAUCHE',
    'CÔTÉ DROIT',
    'INTÉRIEUR',
  ];

  String get stepAngle => stepAngles[currentStep.clamp(0, stepAngles.length - 1)];
  String get stepGuideImage =>
      stepGuideImages[currentStep.clamp(0, stepGuideImages.length - 1)];

  String get stepLabel =>
      stepLabels[currentStep.clamp(0, stepLabels.length - 1)];
  int get totalSteps => stepLabels.length;
  double get progress => (currentStep / totalSteps).clamp(0.0, 1.0);

  InspectionState copyWith({
    InspectionMode? mode,
    int? currentStep,
    bool? isRecording,
    bool? isCompleted,
    bool? cameraReady,
    String? error,
    bool clearError = false,
  }) {
    return InspectionState(
      mode: mode ?? this.mode,
      currentStep: currentStep ?? this.currentStep,
      isRecording: isRecording ?? this.isRecording,
      isCompleted: isCompleted ?? this.isCompleted,
      cameraReady: cameraReady ?? this.cameraReady,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [mode, currentStep, isRecording, isCompleted, cameraReady, error];
}
