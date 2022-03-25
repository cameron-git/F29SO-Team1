import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ivy/screens/profile.dart';
import 'package:provider/provider.dart';
import '../auth.dart';
import 'post.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          ),
          tooltip: 'Profile',
        ),
        title: const Text('Ivy'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const NewPost())),
      ),
      body: const Search(),
    );
  }
}

class Feed extends StatelessWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        // need to handle loading
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Container();
          }
          return ListView(
            children: snapshot.data!.docs.map(
              (e) {
                return Padding(
                  padding: (MediaQuery.of(context).size.width /
                              MediaQuery.of(context).size.height <
                          15 / 9)
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 3,
                          8,
                          MediaQuery.of(context).size.width / 3,
                          8),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Post(e.id),
                      ),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Text(e['title']),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                      e['timestamp'])
                                  .toString()
                                  .substring(0, 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchBoxController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _searchBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchBoxController,
              autofocus: false,
              onChanged: (text) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Search',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchBoxController.text.isEmpty
                  ? const Feed()
                  : FutureBuilder(
                      // need to handle loading
                      future: Future.wait(
                        [
                          FirebaseFirestore.instance
                              .collection('posts')
                              .where('title',
                                  isGreaterThanOrEqualTo:
                                      _searchBoxController.text)
                              .get(),
                          FirebaseFirestore.instance
                              .collection('posts')
                              .where(
                                'tags',
                                arrayContains:
                                    _searchBoxController.text.toUpperCase(),
                              )
                              .get(),
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('name',
                                  isEqualTo: _searchBoxController.text)
                              .get(),
                        ],
                      ),
                      builder: (context,
                          AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<QueryDocumentSnapshot<Object?>> posts =
                            snapshot.data!.elementAt(0).docs;
                        posts.addAll(snapshot.data!.elementAt(1).docs);
                        List<QueryDocumentSnapshot<Object?>> users =
                            snapshot.data!.elementAt(2).docs;
                        List<Widget> listItems = users.map(
                          (e) {
                            return Padding(
                              padding: (MediaQuery.of(context).size.width /
                                          MediaQuery.of(context).size.height <
                                      15 / 9)
                                  ? const EdgeInsets.fromLTRB(0, 8, 0, 8)
                                  : EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width / 3,
                                      8,
                                      MediaQuery.of(context).size.width / 3,
                                      8),
                              child: InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                onTap: () {},
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        (e['photoURL'] != null)
                                            ? ClipOval(
                                                child: Image.network(
                                                  e['photoURL'],
                                                  width: 64,
                                                  height: 64,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(
                                                Icons.account_circle,
                                                size: 64,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(e['name']),
                                            // Do we want to show emails 🤔
                                            //Text(e['email']),
                                          ],
                                        ),
                                        // PLACEHOLDER ICON BUTTON
                                        // Depending where we get to with profiles, was thinking
                                        // that if you pressed the user card it'll take you to a
                                        // dialogue screen but have this iconButton for the time
                                        // being as a placeholder, the widget dialogue can be
                                        // copied over for any profile screen
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: IconButton(
                                            tooltip: "Report user for improper behaviour",
                                            icon: const Icon(
                                              Icons.report, 
                                              color: Color.fromARGB(150, 255, 0, 0),
                                            ),
                                            onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context){
                                                  return ReportUserDialog(e.id);
                                                }
                                              );

                                            },
                                          )
                                        )

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList();
                        listItems.addAll(
                          posts.map(
                            (e) {
                              return Padding(
                                padding: (MediaQuery.of(context).size.width /
                                            MediaQuery.of(context).size.height <
                                        15 / 9)
                                    ? const EdgeInsets.fromLTRB(0, 8, 0, 8)
                                    : EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.width / 3,
                                        8,
                                        MediaQuery.of(context).size.width / 3,
                                        8),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Post(e.id))),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(30),
                                      child: Column(
                                        children: [
                                          Text(e['title']),
                                          Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    e['timestamp'])
                                                .toString()
                                                .substring(0, 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                        return ListView(
                          children: listItems,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportUserDialog extends StatefulWidget{
  const ReportUserDialog(this.userId, {Key? key}) : super (key: key);
  final String userId;



  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog>{
  String dropdownValue = "Spam";
  final TextEditingController _reportUserReasonController = TextEditingController();
  late final User currentUser;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState(){
    currentUser = context.read<AuthService>().currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: const Text("Report User",
              style: TextStyle(fontWeight: FontWeight.bold)
      ),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(children: <Widget> [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 184, 0),
              child: Text("Select reason for user report:"),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              // Drop down button to select one of the reasons 
              // why they're reporting the user
              child: DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.expand_more),
                onChanged: (String? newValue){
                  dropdownValue = newValue!;
                  setState((){});
                },
                // List of all the options available in the drop down menu
                items: <String>[
                  "Spam",
                  "It appears their account is hacked", 
                  "They're pretending to be me or someone else",
                  "Their profile includes abusive or hateful content",
                  "Their messages are abusive or hateful",
                  "They're expressing intention of suicide or self-injury",
                  "They're sharing explicit content",
                  "Other"
                ].map<DropdownMenuItem<String>>((String value){
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _reportUserReasonController,
                decoration: const InputDecoration(
                  labelText: "Further detail",
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Please describe your reason for reporting";
                  }
                  return null;
                },
              )
            )
          ]
          )
        )
      ),
      actions: [
        TextButton(
          onPressed:()=>Navigator.pop(context),
          child: const Text("Cancel",
            style: TextStyle(color: Color.fromARGB(200, 0, 0, 0)),
          )
        ),
        ElevatedButton(
          child: const Text("Submit User Report"),
          onPressed: (){
            // If statement that ensures the user has inputted
            // why they're reporting
            if(_formKey.currentState!.validate()){
              /*FirebaseFirestore.instance
              .collection("users")
              .doc(widget.userId)
              .collection("reports")
              .add({
                "reason": dropdownValue.toString(),
                "description": _reportUserReasonController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "submittedBy": currentUser.uid
              });
              FirebaseFirestore.instance
              .collection("userReports")
              .doc(widget.userId)
              
              .collection("cases")
              .add({
                "reason": dropdownValue.toString(),
                "description": _reportUserReasonController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "submittedBy": currentUser.uid
              });*/
              // Thinking of switching it to very wide userReports collection
              // rather than having the cases to group them together
              FirebaseFirestore.instance
              .collection("userReports")
              .add({
                "reportee": widget.userId,
                "reason": dropdownValue.toString(),
                "description": _reportUserReasonController.text,
                "timestamp": DateTime.now().microsecondsSinceEpoch,
                "submittedBy": currentUser.uid
              });
              Navigator.pop(context);
           }
            
          }
        ),
      ],
    );
  }
}