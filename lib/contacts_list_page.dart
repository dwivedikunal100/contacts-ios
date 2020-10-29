import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts;
  bool _isSelectable = false;
  Map<Contact, bool> _toDelete;

  get iOSLocalizedLabels => true;

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    final contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      _isSelectable = false;
      _contacts = contacts;
      _toDelete =
          Map.fromIterable(contacts, key: (e) => e, value: (e) => false);
    });
  }

  _openContactForm() async {
    try {
      await ContactsService.openContactForm(
          iOSLocalizedLabels: iOSLocalizedLabels,
      );
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts Manager',
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.create),
            onPressed: toggleSelectable,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: _isSelectable ? const Icon(Icons.delete) : const Icon(Icons.add),
          onPressed:
              _isSelectable ? _deleteSelectedContacts : _openContactForm),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts.elementAt(index);
                  return Column(children: [
                    Row(children: [
                      Container(
                        child: checkBoxOrAvatar(c),
                        width: 70,
                      ),
                      Expanded(
                          child: InkWell(
                        onTap: () => _isSelectable ? null : gotoDetailPage(c),
                        child: Text(
                          c.displayName ?? "",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 17.0),
                        ),
                      ))
                    ]),
                    Divider()
                  ]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void gotoDetailPage(Contact contact) {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ContactDetailsPage(
              contact,
              onContactDeviceSave: contactOnDeviceHasBeenUpdated,
            )));
    refreshContacts();
  }

  void _deleteSelectedContacts() {
    _toDelete.forEach((key, value) {
      if (value) {
        ContactsService.deleteContact(key);
      }
    });
    refreshContacts();
  }

  void toggleSelectable() {
    setState(() {
      this._isSelectable = _isSelectable ? false : true;
      _toDelete =
          Map.fromIterable(_contacts, key: (e) => e, value: (e) => false);
    });
  }

  void selectUnSelect(Contact c) {
    _toDelete[c] = _toDelete[c] ? false : true;
    setState(() {
      this._toDelete = _toDelete;
    });
  }

  Widget checkBoxOrAvatar(Contact c) {
    if (_isSelectable) {
      return Checkbox(value: _toDelete[c], onChanged: (x) => selectUnSelect(c));
    } else
      return MaterialButton(
        child: (c.avatar != null && c.avatar.length > 0)
            ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
            : CircleAvatar(child: Text(c.initials())),
        onPressed: () => gotoDetailPage(c),
      );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      final id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }
}

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact, {this.onContactDeviceSave});

  final Contact _contact;
  final Function(Contact) onContactDeviceSave;

  get iOSLocalizedLabels => true;

  _openExistingContactOnDevice(BuildContext context) async {
    try {
      final contact = await ContactsService.openExistingContact(_contact,
          iOSLocalizedLabels: iOSLocalizedLabels);
      if (onContactDeviceSave != null) {
        onContactDeviceSave(contact);
      }
      Navigator.of(context).pop();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ContactsService.deleteContact(_contact);
              Navigator.pop(context);
            },
          ),
          IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openExistingContactOnDevice(context)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const ext("Avatar"),
              trailing: (_contact.avatar != null && _contact.avatar.length > 0)
                  ? CircleAvatar(backgroundImage: MemoryImage(_contact.avatar))
                  : CircleAvatar(child: Text(_contact.initials())),
            ),
            ListTile(
              title: const Text("Name"),
              trailing: Text(_contact.givenName ?? ""),
            ),
            ListTile(
              title: const Text("Middle name"),
              trailing: Text(_contact.middleName ?? ""),
            ),
            ListTile(
              title: const Text("Family name"),
              trailing: Text(_contact.familyName ?? ""),
            ),
            ListTile(
              title: const Text("Prefix"),
              trailing: Text(_contact.prefix ?? ""),
            ),
            ListTile(
              title: const Text("Suffix"),
              trailing: Text(_contact.suffix ?? ""),
            ),
            ListTile(
              title: const Text("Birthday"),
              trailing: Text(_contact.birthday != null
                  ? _contact.birthday.toString()
                  : ""),
            ),
            ListTile(
              title: const Text("Company"),
              trailing: Text(_contact.company ?? ""),
            ),
            ListTile(
              title: const Text("Job"),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            ListTile(
              title: const Text("Account Type"),
              trailing: Text((_contact.androidAccountType != null)
                  ? _contact.androidAccountType.toString()
                  : ""),
            ),
            AddressesTile(_contact.postalAddresses),
            ItemsTile("Phones", _contact.phones),
            ItemsTile("Emails", _contact.emails)
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
                          title: const Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        ListTile(
                          title: const Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        ListTile(
                          title: const 
                        ListTile(
                          title: const Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        ListTile(
                          title: const Text("Country"),
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
