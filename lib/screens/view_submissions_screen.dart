import 'package:flutter/material.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

class ViewSubmissionsScreen extends StatefulWidget {
  const ViewSubmissionsScreen({super.key});

  @override
  State<ViewSubmissionsScreen> createState() => _ViewSubmissionsScreenState();
}

class _ViewSubmissionsScreenState extends State<ViewSubmissionsScreen> {
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 7),
            bodyWidgetWhiteBG(
                context,
                switchedLoadingContainer(
                    _isLoading,
                    horizontalPadding5Percent(
                        context,
                        Column(
                          children: [],
                        ))))
          ],
        ));
  }
}
