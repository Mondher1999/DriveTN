import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/app_colors.dart';
import 'widgets/car_angle_diagram.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../bloc/inspection_cubit.dart';
import '../bloc/inspection_state.dart';

class Video360Screen extends StatefulWidget {
  final String bookingId;
  final InspectionMode mode;
  const Video360Screen({
    super.key,
    required this.bookingId,
    required this.mode,
  });

  @override
  State<Video360Screen> createState() => _Video360ScreenState();
}

class _Video360ScreenState extends State<Video360Screen> {
  CameraController? _controller;
  bool _useFallback = false;
  bool _initializing = true;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionCubit>().start(widget.mode);
    });
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _useFallback = true;
          _initializing = false;
        });
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _useFallback = true;
          _initializing = false;
        });
        return;
      }
      final rear = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(rear, ResolutionPreset.medium);
      await controller.initialize();
      if (!mounted) return;
      _controller = controller;
      setState(() {
        _initializing = false;
      });
      if (mounted) {
        context.read<InspectionCubit>().setCameraReady(true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _useFallback = true;
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startRecordingTick() {
    _recordTimer?.cancel();
    setState(() => _recordSeconds = 0);
    HapticFeedback.mediumImpact();
    context.read<InspectionCubit>().startRecordingStep();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _recordSeconds++);
      if (_recordSeconds >= 5) {
        t.cancel();
        if (!mounted) return;
        context.read<InspectionCubit>().nextStep();
      }
    });
  }

  Future<void> _runFallback() async {
    await context.read<InspectionCubit>().simulateAll();
  }

  void _onCompleted(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vidéo enregistrée')),
    );
    final cubit = context.read<InspectionCubit>();
    if (widget.mode == InspectionMode.pickup) {
      cubit.completePickup(widget.bookingId);
      context.go('/unlock/${widget.bookingId}');
    } else {
      cubit.completeReturn(widget.bookingId);
      context.go('/lock/${widget.bookingId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<InspectionCubit, InspectionState>(
        listenWhen: (p, c) => !p.isCompleted && c.isCompleted,
        listener: (ctx, state) => _onCompleted(ctx),
        child: BlocBuilder<InspectionCubit, InspectionState>(
          builder: (context, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (_controller != null && _controller!.value.isInitialized)
                  CameraPreview(_controller!)
                else
                  Container(color: Colors.black),

                // Quit button top-right
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => context.go('/home/rentals'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Quitter',
                        style: AppTypography.caps(
                          size: 10,
                          letterSpacing: 0.5,
                          color: AppColors.surface.withValues(alpha: 0.9),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top pill step indicator (replaces old circular 6-angle indicator)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${state.currentStep + 1} / ${state.totalSteps}',
                            style: AppTypography.caps(
                              size: 10,
                              letterSpacing: 1.6,
                              color: AppColors.surface,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 12,
                            color: AppColors.surface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            state.stepAngle,
                            style: AppTypography.caps(
                              size: 10,
                              letterSpacing: 1.6,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Guide image card — shows the user what kind of shot to take
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.4),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: CarAngleDiagram(
                              key: ValueKey(state.currentStep),
                              step: state.currentStep,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.eye,
                                size: 12,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'EXEMPLE — ${state.stepAngle}',
                                style: AppTypography.caps(
                                  size: 9,
                                  letterSpacing: 1.6,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate(key: ValueKey('guide-${state.currentStep}'))
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: -0.1,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                        ),
                  ),
                ),

                // Center frame
                Center(
                  child: Container(
                    width: 240,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cadrer ici',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Step instruction text — prominent label above the record button
                Positioned(
                  bottom: 200,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      state.stepLabel,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w800,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),

                // Progress bar — uses 5-step state.progress
                Positioned(
                  bottom: 180,
                  left: 24,
                  right: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ((state.currentStep + 1) / state.totalSteps)
                          .clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor:
                          AppColors.surface.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ),

                // Bottom controls
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _useFallback
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Mode démo — la caméra n'est pas disponible",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                PrimaryButton(
                                  label: 'Simuler la vidéo (3s)',
                                  loading: state.isRecording,
                                  onPressed: _runFallback,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (state.isRecording)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '● REC ${_recordSeconds}s / 5s',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: state.isRecording
                                      ? null
                                      : _startRecordingTick,
                                  child: SizedBox(
                                    width: 92,
                                    height: 92,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 92,
                                          height: 92,
                                          child: CircularProgressIndicator(
                                            value: state.isRecording
                                                ? (_recordSeconds / 5)
                                                    .clamp(0.0, 1.0)
                                                : 0,
                                            strokeWidth: 4,
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.25),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                              AppColors.accent,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: AppColors.danger,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                          child: Center(
                                            child: state.isRecording
                                                ? Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration:
                                                        BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(4),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                if (_initializing)
                  const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
