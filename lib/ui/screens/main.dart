import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterclient/api/auth.dart';
import 'package:flutterclient/fontawesome/font_awesome_icons.dart';
import 'package:flutterclient/logging.dart';
import 'package:flutterclient/ui/themes.dart';
import 'package:flutterclient/ui/uihelpers.dart';
import 'package:flutterclient/ui/screens/create.dart';
import 'package:flutterclient/ui/screens/home.dart';
import 'package:flutterclient/ui/screens/profile.dart';
import 'package:flutterclient/ui/widget/user_profile.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab;
  StreamController<NavInfo> _changeNotifier = new StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;
  }

  Widget _navBar() {
    ThemeData theme = _selectedTab == 0 ? darkTheme : lightTheme;
    return Container(
      decoration: _selectedTab == 0
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: theme.accentColor,
                ),
              ),
            ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.video_plus_solid),
            title: Text("Create"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text("Chat"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          ),
        ],
        backgroundColor: theme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTab,
        showUnselectedLabels: true,
        selectedItemColor: theme.textTheme.bodyText1.color,
        unselectedItemColor: theme.accentColor,
        onTap: (index) {
          // Special logic for the create tab
          if (index == 2) {
            _changeNotifier.sink.add(NavInfo(type: NavInfoType.Overlay, from: _selectedTab, to: -1));
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FullscreenCamera();
                },
                transitionsBuilder: slideFrom(0.0, 1.0),
              ),
            ).then((_) {
              _changeNotifier.sink.add(NavInfo(type: NavInfoType.Overlay, from: -1, to: _selectedTab));
            });
          } else {
            setState(() {
              _changeNotifier.sink.add(NavInfo(
                type: NavInfoType.Tab,
                from: _selectedTab,
                to: index,
              ));
              _selectedTab = index;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = _selectedTab == 0 ? darkTheme : Theme.of(context);
    // Double scaffold allows the bottomSheet to display on top of bottomNavBar
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ProfileScreenNotification) {
          logger.i("Profile screen ${notification.opened ? "opened" : "closed"}");
          _changeNotifier.sink.add(NavInfo(
            type: NavInfoType.Overlay,
            from: notification.opened ? _selectedTab : -1,
            to: notification.opened ? -1 : _selectedTab,
          ));
          return true;
        } else
          return false;
      },
      child: Scaffold(
        body: Scaffold(
          backgroundColor: theme.backgroundColor,
          body: SafeArea(
            child: IndexedStack(
              children: <Widget>[
                HomeTab(
                  shouldTriggerChange: _changeNotifier.stream,
                ),
                Container(),
                Container(),
                Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text("Chat"),
                ),
                ProfileTab(AuthInfo.instance().username),
              ],
              index: _selectedTab,
            ),
          ),
          bottomNavigationBar: _navBar(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _changeNotifier.close();
    super.dispose();
  }
}
