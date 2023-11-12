import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class EditFAQScreen extends StatefulWidget {
  final String faqID;
  const EditFAQScreen({super.key, required this.faqID});

  @override
  State<EditFAQScreen> createState() => _EditFAQScreenState();
}

class _EditFAQScreenState extends State<EditFAQScreen> {
  bool _isLoading = true;
  bool _isInitialzied = false;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialzied) getThisFAQ();
  }

  @override
  void dispose() {
    super.dispose();
    _questionController.dispose();
    _answerController.dispose();
  }

  void getThisFAQ() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final faq = await FirebaseFirestore.instance
          .collection('faqs')
          .doc(widget.faqID)
          .get();
      final faqData = faq.data()!;

      _questionController.text = faqData['question'];
      _answerController.text = faqData['answer'];

      setState(() {
        _isLoading = false;
        _isInitialzied = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting this FAQ data: $error')));
    }
  }

  void uploadChangesToFAQ() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    //  INPUT VALIDATORS
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      //  Create new announcement entry and upload to Firebase.
      await FirebaseFirestore.instance
          .collection('faqs')
          .doc(widget.faqID)
          .update({
        'question': _questionController.text,
        'answer': _answerController.text
      });

      setState(() {
        _isLoading = false;
      });

      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully edited this FAq!')));
      goRouter.go('/faqs');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error editing this faq: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 6),
            bodyWidgetWhiteBG(
                context,
                stackedLoadingContainer(
                    context,
                    _isLoading,
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _backButton(),
                          horizontalPadding5Percent(
                              context,
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _editAnnouncementHeader(),
                                    _questionWidget(),
                                    _answerWidget(),
                                    Gap(30),
                                    _submitButton()
                                  ],
                                ),
                              )),
                        ],
                      ),
                    )))
          ],
        ));
  }

  Widget _backButton() {
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => GoRouter.of(context).go('/faqs'))
    ]);
  }

  Widget _editAnnouncementHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: AutoSizeText(
        'EDIT FAQ',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _questionWidget() {
    return Column(children: [
      vertical10horizontal4(
          Row(children: [AutoSizeText('Question', style: interSize19())])),
      YouthConnectTextField(
          text: 'Question',
          controller: _questionController,
          textInputType: TextInputType.text,
          displayPrefixIcon: null),
      Gap(20)
    ]);
  }

  Widget _answerWidget() {
    return Column(children: [
      vertical10horizontal4(
          Row(children: [AutoSizeText('Answer', style: interSize19())])),
      YouthConnectTextField(
          text: 'Answer',
          controller: _answerController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
      Gap(20)
    ]);
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
            onPressed: uploadChangesToFAQ,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: AutoSizeText('SUBMIT',
                  style:
                      GoogleFonts.poppins(textStyle: whiteBoldStyle(size: 18))),
            ))
      ]),
    );
  }
}
