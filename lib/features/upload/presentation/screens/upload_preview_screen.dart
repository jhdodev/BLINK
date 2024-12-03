import 'dart:io';

import 'package:blink/features/upload/presentation/blocs/preview/preview_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class UploadPreviewScreen extends StatefulWidget {
  final String videoPath;

  const UploadPreviewScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<UploadPreviewScreen> createState() => _UploadPreviewScreenState();
}

class _UploadPreviewScreenState extends State<UploadPreviewScreen> {
  late final PreviewBloc _previewBloc;

  @override
  void initState() {
    super.initState();
    _previewBloc = PreviewBloc()..add(InitializeVideo(widget.videoPath));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _previewBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<PreviewBloc, PreviewState>(
            builder: (context, state) {
              if (state is VideoPlayerLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (state is VideoPlayerReady) {
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: state.controller.value.aspectRatio,
                              child: VideoPlayer(state.controller),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (state.isPlaying) {
                                context.read<PreviewBloc>().add(PauseVideo());
                              } else {
                                context.read<PreviewBloc>().add(PlayVideo());
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(state.position),
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              state.controller,
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              colors: VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.grey[800]!,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(state.duration),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.push('/upload_detail', extra: widget.videoPath);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                            child: Text('다음'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (state is VideoPlayerError) {
                return Center(child: Text(state.message));
              }

              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _previewBloc.add(DisposeVideo());
    _previewBloc.close();  // BLoC 정리
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}