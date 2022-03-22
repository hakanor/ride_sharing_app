import 'package:flutter/material.dart';
class PersonalAdsPage extends StatefulWidget {
  const PersonalAdsPage({Key? key}) : super(key: key);

  @override
  _PersonalAdsState createState() => _PersonalAdsState();
}

class _PersonalAdsState extends State<PersonalAdsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("bu sayfada kişinin aktif ilanları gözükmesi beklenmekte"),
      ),
    );
  }
}
