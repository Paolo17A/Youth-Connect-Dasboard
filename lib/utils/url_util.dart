import 'package:url_launcher/url_launcher.dart';

launchURL(String _url) async {
  final url = Uri.parse(_url);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    // Handle the case where the URL cannot be launched
    print('Could not launch $url');
  }
}
