import 'package:flutter/material.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class OrgHomeScreen extends StatefulWidget {
  const OrgHomeScreen({super.key});

  @override
  State<OrgHomeScreen> createState() => _OrgHomeScreenState();
}

class _OrgHomeScreenState extends State<OrgHomeScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orgAppBarWidget(context),
      body: Row(
        children: [
          orgLeftNavigator(context, 0),
          bodyWidgetWhiteBG(
              context,
              switchedLoadingContainer(
                  _isLoading,
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Column(),
                    ),
                  )))
        ],
      ),
    );
  }
}
