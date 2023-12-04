import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';

import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class AddFAQScreen extends StatefulWidget {
  const AddFAQScreen({super.key});

  @override
  State<AddFAQScreen> createState() => _AddFAQScreenState();
}

class _AddFAQScreenState extends State<AddFAQScreen> {
  bool _isLoading = false;
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoggedInUser()) {
        GoRouter.of(context).goNamed(GoRoutes.login);
        return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _questionController.dispose();
    _answerController.dispose();
  }

  Future addNewForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please enter the question and answer.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String faqID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('faqs').doc(faqID).set({
        'question': _questionController.text,
        'answer': _answerController.text
      });

      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully added new FAQ!')));
      goRouter.go('/faqs');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding new FAQ: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: Row(
        children: [
          leftNavigator(context, 3),
          bodyWidgetMercuryBG(
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
                            Column(children: [
                              _newFAQWidget(),
                              _questionWidget(),
                              _answerWidget(),
                              Gap(30),
                              _submitButtonWidget()
                            ])),
                      ],
                    ),
                  )))
        ],
      ),
    );
  }

  Widget _backButton() {
    return Row(children: [
      backToViewScreenButton(context,
          onPress: () => GoRouter.of(context).go('/faqs'))
    ]);
  }

  Widget _newFAQWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: AutoSizeText(
        'NEW FAQ',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 38)),
      ),
    );
  }

  Widget _questionWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Question', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
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
      vertical10horizontal4(Row(children: [
        AutoSizeText('Answer', style: interSize19()),
        AutoSizeText('*', style: interSize19(textColor: Colors.red))
      ])),
      YouthConnectTextField(
          text: 'Answer',
          controller: _answerController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
      Gap(20)
    ]);
  }

  Widget _submitButtonWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: addNewForm,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 88, 147, 201),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: AutoSizeText(
                'SUBMIT',
                style: GoogleFonts.poppins(
                  textStyle: whiteBoldStyle(size: 18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
