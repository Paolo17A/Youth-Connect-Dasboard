import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_miscellaneous_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/color_util.dart';
import '../widgets/custom_padding_widgets.dart';

class OrgHomeScreen extends StatefulWidget {
  const OrgHomeScreen({super.key});

  @override
  State<OrgHomeScreen> createState() => _OrgHomeScreenState();
}

class _OrgHomeScreenState extends State<OrgHomeScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  List<DocumentSnapshot> allAnnouncements = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getAllAnnouncements();
  }

  void getAllAnnouncements() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final announcements =
          await FirebaseFirestore.instance.collection('announcements').get();
      allAnnouncements = announcements.docs;
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting all announcements: $error')));
    }
  }

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
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _orgRenewalWidgets(),
                          Gap(40),
                          _announcementsContainer()
                        ],
                      ),
                    ),
                  )))
        ],
      ),
    );
  }

  Widget _orgRenewalWidgets() {
    return Row(
      children: [
        orgDashboardWidget(context,
            label: 'Closed',
            buttonLabel: 'Renew',
            displayIcon:
                Image.asset('assets/images/icons/organization.png', scale: 2),
            onPress: () => _displayRenewOrgDialog()),
        orgDashboardWidget(context,
            label: 'Approved',
            buttonLabel: 'Status',
            displayIcon: Icon(
              Icons.thumb_up,
              color: Colors.green,
            ),
            onPress: () {})
      ],
    );
  }

  Widget _announcementsContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
          color: CustomColors.softBlue,
          borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [
              AutoSizeText(
                'Announcements',
                style: blackBoldStyle(),
              ),
            ]),
            allAnnouncements.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allAnnouncements.length,
                    itemBuilder: (context, index) {
                      //  Local variables for better readability
                      final announcement = allAnnouncements[index].data()
                          as Map<dynamic, dynamic>;
                      String title = announcement['title'];
                      String content = announcement['content'];
                      Timestamp dateAdded = announcement['dateAdded'];
                      DateTime dateAnnounced = dateAdded.toDate();
                      String formattedDateAnnounced =
                          DateFormat('dd MMM yyyy').format(dateAnnounced);
                      List<dynamic> imageURLs = announcement['imageURLs'];
                      return GestureDetector(
                          onTap: () {},
                          child: announcementEntryContainer(imageURLs,
                              formattedDateAnnounced, title, content));
                    })
                : Center(
                    child:
                        Text('No ANNOUNCEMENTS YET', style: blackBoldStyle()))
          ],
        ),
      ),
    );
  }

  Widget announcementEntryContainer(List<dynamic> imageURLs,
      String formattedDateAnnounced, String title, String content) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
            height: 100,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                if (imageURLs.isNotEmpty)
                  allPadding4pix(_miniNetworkImage(imageURLs[0])),
                announcementEntryTextContainer(
                    imageURLs, formattedDateAnnounced, title, content)
              ],
            )));
  }

  Widget announcementEntryTextContainer(List<dynamic> imageURLs,
      String formattedDateAnnounced, String title, String content) {
    return SizedBox(
      width: imageURLs.isNotEmpty
          ? MediaQuery.of(context).size.width * 0.45
          : MediaQuery.of(context).size.width * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          allPadding4pix(
              Text(formattedDateAnnounced, style: TextStyle(fontSize: 14))),
          horizontalPadding5pix(Text(title, style: titleTextStyle())),
          horizontalPadding5pix(SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 40,
            child: Text(content, softWrap: true, style: contentTextStyle()),
          ))
        ],
      ),
    );
  }

  Widget _miniNetworkImage(String src) {
    return Container(
      width: 80,
      height: 80,
      child: Image.network(src),
    );
  }

  void _displayRenewOrgDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: loginBoxContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'You can now apply for accredition in our office.',
                          style: blackBoldStyle(),
                        ),
                        Divider(thickness: 2),
                        allPadding8Pix(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'Step 1. Download the accreditation form below.',
                              style: blackBoldStyle(),
                            ),
                            TextButton(
                                onPressed: () {},
                                child: AutoSizeText(
                                  'DOWNLOAD LINK',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                )),
                            Gap(25),
                            AutoSizeText(
                              'Step 2. Upload the filled out form here.',
                              style: blackBoldStyle(),
                            ),
                          ],
                        ))
                      ],
                    ),
                  )),
            ));
  }
}
