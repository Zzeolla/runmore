import 'package:flutter/material.dart';
import 'package:runmore/screen/badge_screen.dart';
import 'package:runmore/screen/location_share/location_share_screen.dart';
import 'package:runmore/screen/my_info_screen.dart';
import 'package:runmore/screen/history_screen.dart';
import 'package:runmore/screen/run/run_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    RunScreen(),
    HistoryScreen(),
    LocationShareScreen(),
    BadgeScreen(),
    MyInfoScreen(),
  ];

  void _onItemTapped(int index) {
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F4), // Cream White
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5EF), // 탭 구분선
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, -1),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,

        // 색상 새롭게 적용
        selectedItemColor: const Color(0xFF5B8CFF), // 스포티 블루
        unselectedItemColor: const Color(0xFFB4B4B4),

        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Text('🏃‍♂️', style: TextStyle(fontSize: 22)),
            activeIcon:
            Text('🏃‍♂️', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            label: '달리기',
          ),
          BottomNavigationBarItem(
            icon: Text('📊', style: TextStyle(fontSize: 22)),
            activeIcon:
            Text('📊', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Text('📍', style: TextStyle(fontSize: 22)),
            activeIcon:
            Text('📍', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              label: '함께달리기',
          ),
          BottomNavigationBarItem(
            icon: Text('🏅', style: TextStyle(fontSize: 22)),
            activeIcon:
            Text('🏅', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            label: '도전',
          ),
          BottomNavigationBarItem(
            icon: Text('🙂', style: TextStyle(fontSize: 22)),
            activeIcon:
            Text('🙂', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            label: '내 정보',
          ),
        ],
      ),
    );
  }

}
