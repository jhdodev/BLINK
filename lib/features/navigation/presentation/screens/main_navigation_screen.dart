import 'package:blink/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:blink/features/home/presentation/screens/home_screen.dart';
import 'package:blink/features/point/presentation/screens/point_screen.dart';
import 'package:blink/features/upload/presentation/screens/upload_screen.dart';
import 'package:blink/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:blink/features/profile/presentation/screens/profile_screen.dart';
import 'package:blink/features/user/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, required this.initialIndex});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('이 기능을 사용하려면 로그인이 필요합니다.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                setState(() {
                  _selectedIndex = 4;
                });
              },
              child: const Text('로그인하기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex,
        children: [
          HomeScreen(key: homeKey),
          currentUser == null
              ? const LoginScreen()
              : PointScreen(),
          const NotificationsScreen(),
          currentUser == null
              ? const LoginScreen()
              : ProfileScreen(userId: currentUser.uid),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex == 0) {
            homeKey.currentState?.savePlayingState();
            homeKey.currentState?.pauseAllVideos();
          }

          if (index == 2) {
            // 업로드 버튼
            if (currentUser == null) {
              _showLoginDialog();
            } else {
              homeKey.currentState?.savePlayingState();
              homeKey.currentState?.pauseAllVideos();
              context.push('/upload_camera');
            }
          } else if (index == 1 || index == 4) {
            // 포인트 및 프로필 탭
            if (currentUser == null) {
              _showLoginDialog();
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          } else {
            // 홈 및 알림 탭
            setState(() {
              _selectedIndex = index;
            });

            if (index == 0) {
              homeKey.currentState?.resumeVideoIfNeeded();
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '포인트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '업로드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
