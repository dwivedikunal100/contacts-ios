import 'package:contactsios/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Contacts Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool value = false;

  void _incrementCounter() {
    setState(() {
      value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    getContacts();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          MaterialButton(
            padding: EdgeInsets.all(8.0),
            minWidth: 0,
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: null,
          ),
          MaterialButton(
            padding: EdgeInsets.all(8.0),
            minWidth: 0,
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () => null,
          ),
        ],
      ),
      body: Container(
        child: buildContacts(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    return contacts.toList();
  }

  FutureBuilder buildContacts() {
    return FutureBuilder(
        future: getContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = snapshot.data[index];
                  return Column(children: [
                    ListTile(
                      leading: (c.avatar != null && c.avatar.length > 0)
                          ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                          : CircleAvatar(child: Text(c.initials())),
                      title: Text(snapshot.data[index].displayName),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DetailPage(contact: snapshot.data[index])),
                      ),
                    ),
                    Divider()
                  ]);
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }

// flutter emulator --launch apple_ios_simulator
}
