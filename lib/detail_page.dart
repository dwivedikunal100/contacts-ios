import 'package:flutter/material.dart';

import 'package:contacts_service/contacts_service.dart';

class DetailPage extends StatelessWidget {
  final Contact contact;

  DetailPage({this.contact});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.displayName ?? ""),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: () => shareVCFCard(context, contact: _contact),
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => ContactsService.deleteContact(contact),
          ),
          IconButton(icon: Icon(Icons.update), onPressed: () => null),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => null,
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Name"),
              trailing: Text(contact.givenName ?? ""),
            ),
            ListTile(
              title: Text("Middle name"),
              trailing: Text(contact.middleName ?? ""),
            ),
            ListTile(
              title: Text("Family name"),
              trailing: Text(contact.familyName ?? ""),
            ),
            ListTile(
              title: Text("Prefix"),
              trailing: Text(contact.prefix ?? ""),
            ),
            ListTile(
              title: Text("Suffix"),
              trailing: Text(contact.suffix ?? ""),
            ),
            ListTile(
              title: Text("Birthday"),
              trailing: Text(contact.birthday != null
                  ? contact.birthday.toIso8601String()
                  : ""),
            ),
            ListTile(
              title: Text("Company"),
              trailing: Text(contact.company ?? ""),
            ),
            ListTile(
              title: Text("Job"),
              trailing: Text(contact.jobTitle ?? ""),
            ),
            ListTile(
              title: Text("Account Type"),
              trailing: Text((contact.androidAccountType != null)
                  ? contact.androidAccountType.toString()
                  : ""),
            ),
            AddressesTile(contact.postalAddresses),
            ItemsTile("Phones", contact.phones),
            ItemsTile("Emails", contact.emails)
          ],
        ),
      ),
    );
  }
}

class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text("Addresses")),
        Column(
          children: _addresses
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        ListTile(
                          title: Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        ListTile(
                          title: Text("City"),
                          trailing: Text(a.city ?? ""),
                        ),
                        ListTile(
                          title: Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        ListTile(
                          title: Text("Country"),
                          trailing: Text(a.country ?? ""),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
