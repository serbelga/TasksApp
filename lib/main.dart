import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: primaryColor,
        primaryTextTheme: TextTheme(
            title: TextStyle(
                //color: const Color(0xFF4688F1),

                )),
        accentColor: primaryColor, //FAB color
        /*
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.red,
          textTheme: ButtonTextTheme.normal,
        ),*/
      ),
      home: MyHomePage(title: 'My tasks'),
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
  void _createTask() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyCustomForm()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: new BottomAppBar(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Add a new task'),
        onPressed: _createTask,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: _buildBody(context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.title),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      //Padding of ListItem
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ExpansionTile(
            title: RichText(
              text: TextSpan(
                text: record.title,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            //trailing: Text(record.body),
            children: <Widget>[
              ListTile(title: Text(record.body)),
            ]),
      ),
    );
  }
}

class Record {
  final String title;
  final String body;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['title'] != null),
        assert(map['body'] != null),
        title = map['title'],
        body = map['body'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$body>";
}


// Define a Custom Form Widget
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class. This class will hold the data related to
// our Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final titleTextController = TextEditingController();
  final bodyTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 12.0, right: 12.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: titleTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: bodyTextController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          )
      ),
      floatingActionButton: new FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () => Firestore.instance.runTransaction((transaction) async {
          Map<String, dynamic> data = new Map();
          if (titleTextController.text == "" || bodyTextController.text == "") {

            Navigator.pop(context);
          } else {
            data['title'] = titleTextController.text;
            data['body'] = bodyTextController.text;
            Firestore.instance.collection('tasks').add(data);
            Navigator.pop(context);
          }
        }),
      ),
    );
  }
}
