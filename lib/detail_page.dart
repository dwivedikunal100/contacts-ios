import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';

class DetailPage extends StatelessWidget {
  final Contact contact;

  DetailPage({@required this.contact});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(title: Text(contact.toMap().toString())),
            ListTile(
              title: Text("Name"),
              trailing: Text(contact.displayName),
            ),
            ListTile(
              title: Text("Phones"),
              trailing: Column(
                  children: contact.phones
                      .map((e) => Text(e.value.toString()))
                      .toList()),
            ),
            ListTile(
              title: Text("Email address"),
              trailing: Column(
                  children: contact.emails
                      .map((e) => Text(e.value.toString()))
                      .toList()),
            ),
            ListView(
              children: contact.,
            )
          ],
        ),
      ),
    );
  }
}
