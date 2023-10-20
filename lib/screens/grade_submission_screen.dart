import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ywda_dashboard/widgets/app_bar_widget.dart';
import 'package:ywda_dashboard/widgets/custom_container_widgets.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';
import 'package:ywda_dashboard/widgets/left_navigation_bar_widget.dart';
import 'package:ywda_dashboard/widgets/youth_connect_textfield_widget.dart';

import '../widgets/custom_text_widgets.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final String skill;
  final String subSkill;
  final String clientID;
  const GradeSubmissionScreen(
      {super.key,
      required this.skill,
      required this.subSkill,
      required this.clientID});

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  bool _isLoading = true;
  final _titleController = TextEditingController();
  String content = '';
  final _contentController = TextEditingController();
  String taskType = '';
  bool _doneInitializing = false;
  final _remarksController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSubskillEntry();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _remarksController.dispose();
  }

  Future getSubskillEntry() async {
    if (_doneInitializing) {
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final client = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientID)
          .get();
      final clientData = client.data()!;

      Map<dynamic, dynamic> thisSubskill =
          clientData['skillsDeveloped'][widget.skill][widget.subSkill];
      //  VIDEO
      if (thisSubskill.containsKey('videoTitle')) {
        taskType = 'VIDEO';
        _titleController.text = thisSubskill['videoTitle'];
        content = thisSubskill['videoURL'];
        _contentController.text = content;
      }
      //  ESSAY
      else if (thisSubskill.containsKey('essayTitle')) {
        taskType = 'ESSAY';
        _titleController.text = thisSubskill['essayTitle'];
        content = thisSubskill['essayContent'];
        _contentController.text = content;
      }

      setState(() {
        _isLoading = false;
        _doneInitializing = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting subskill entry: $error')));
    }
  }

  Future denySubmission() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      final client = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientID)
          .get();
      Map<dynamic, dynamic> skillsDeveloped = client.data()!['skillsDeveloped'];
      skillsDeveloped[widget.skill][widget.subSkill]['status'] = 'DENIED';
      if (_remarksController.text.isNotEmpty) {
        skillsDeveloped[widget.skill][widget.subSkill]['remarks'] =
            _remarksController.text.trim();
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientID)
          .update({'skillsDeveloped': skillsDeveloped});

      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully denied this entry')));
      goRouter.go('/submissions');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error denying this submission: $error')));
    }
  }

  Future approveSubmission(int grade) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      final client = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientID)
          .get();
      Map<dynamic, dynamic> skillsDeveloped = client.data()!['skillsDeveloped'];
      skillsDeveloped[widget.skill][widget.subSkill]['status'] = 'GRADED';
      skillsDeveloped[widget.skill][widget.subSkill]['grade'] = grade;
      if (_remarksController.text.isNotEmpty) {
        skillsDeveloped[widget.skill][widget.subSkill]['remarks'] =
            _remarksController.text.trim();
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientID)
          .update({'skillsDeveloped': skillsDeveloped});

      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Successfully approved this entry')));
      goRouter.go('/submissions');
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error denying this submission: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(context),
        body: Row(
          children: [
            leftNavigator(context, 7),
            bodyWidgetWhiteBG(
                context,
                stackedLoadingContainer(
                    context,
                    _isLoading,
                    SingleChildScrollView(
                      child: horizontalPadding5Percent(
                          context,
                          Column(
                            children: [
                              _skillAndSubksillHeaderWidget(),
                              _entryTitleWidget(),
                              const SizedBox(height: 30),
                              if (taskType == 'VIDEO') _entryVideoWidget(),
                              if (taskType == 'ESSAY') _entryEssayWidget(),
                              const SizedBox(height: 50),
                              _selectableActionsWidget(),
                              _remarksWidget(),
                              const SizedBox(height: 50)
                            ],
                          )),
                    )))
          ],
        ));
  }

  Widget _skillAndSubksillHeaderWidget() {
    return verticalPadding5Percent(
        context,
        Center(
          child: AutoSizeText(
            '${widget.skill} - ${widget.subSkill}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ),
        ));
  }

  Widget _entryTitleWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Entry Title', style: interSize19()),
      ])),
      YouthConnectTextField(
        text: 'Entry Title',
        controller: _titleController,
        textInputType: TextInputType.text,
        displayPrefixIcon: null,
        enabled: false,
      ),
      const SizedBox(height: 20)
    ]);
  }

  Widget _entryVideoWidget() {
    return Column(children: [
      Row(children: [
        AutoSizeText('Video URL', style: interSize19()),
      ]),
      vertical10horizontal4(
        Row(
          children: [
            TextButton(
                onPressed: () {
                  _launchURL(content);
                },
                child: AutoSizeText(content, style: interSize19())),
          ],
        ),
      ),
      const SizedBox(height: 20)
    ]);
  }

  Widget _entryEssayWidget() {
    return Column(children: [
      vertical10horizontal4(Row(children: [
        AutoSizeText('Entry Essay', style: interSize19()),
      ])),
      YouthConnectTextField(
        text: 'Essay Content',
        controller: _contentController,
        textInputType: TextInputType.multiline,
        displayPrefixIcon: null,
        enabled: false,
      ),
      const SizedBox(height: 20)
    ]);
  }

  Widget _selectableActionsWidget() {
    return Column(children: [
      Row(children: [
        AutoSizeText('ACTIONS', style: interSize19()),
      ]),
      horizontalPadding5Percent(
          context,
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: _actionButtonWidget('DENY SUBMISSION', () {
                    denySubmission();
                  }, Colors.red),
                ),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _actionButtonWidget('GRANT 1 BADGE (BRONZE)', () {
                      approveSubmission(1);
                    }, Colors.brown),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _actionButtonWidget('GRANT 2 BADGES (SILVER)', () {
                      approveSubmission(2);
                    }, Colors.grey),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _actionButtonWidget('GRANT 3 BADGES (GOLD)', () {
                      approveSubmission(3);
                    }, const Color.fromARGB(255, 180, 164, 14)),
                  ))
            ],
          )),
      const SizedBox(height: 20)
    ]);
  }

  Widget _remarksWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              AutoSizeText('Optional Remarks',
                  style: GoogleFonts.inter(
                      textStyle: const TextStyle(fontSize: 19))),
            ],
          ),
        ),
        YouthConnectTextField(
            text: 'Optional Remarks',
            controller: _remarksController,
            textInputType: TextInputType.multiline,
            displayPrefixIcon: null),
      ],
    );
  }

  Widget _actionButtonWidget(
      String label, Function selectImage, Color thisColor) {
    return ElevatedButton(
        onPressed: () {
          selectImage();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: thisColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: AutoSizeText(label,
              style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))),
        ));
  }

  _launchURL(String path) async {
    final url = Uri.parse(path);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle the case where the URL cannot be launched
      //  print('Could not launch $url');
    }
  }
}
