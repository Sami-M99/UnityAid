import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';

class HelpRequests extends StatefulWidget {
  const HelpRequests({Key? key}) : super(key: key);

  @override
  State<HelpRequests> createState() => _HelpRequestsState();
}

class _HelpRequestsState extends State<HelpRequests> {
  String messages = "";
  String sender = "";
  String address = "";
  final date = DateTime.now();
  List<QueryDocumentSnapshot> documents = [];
  @override
  void initState() {
    super.initState();
    mess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF000116),
          title: const Text("Yardım Talepleri"),
          centerTitle: true,
          actions: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(Icons.delete_forever_rounded, size: 35),
                    onPressed: () {
                      deleteAlert();
                    },
                    tooltip: "Talepleri Siler",
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 50),
              child: mess(),
            ),
          ),
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 30),
        //   child: FloatingActionButton.extended(
        //     onPressed: deleteAlert,
        //     label: const Text("Talepler Sil"),
        //     icon: const Icon(Icons.delete_forever),
        //     backgroundColor: Color.fromARGB(255, 3, 6, 59),
        //   ),
        // ),
      ),
    );
  }

  Widget mess() {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('messages')
            .orderBy('date', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<QueryDocumentSnapshot> documents =
              snapshot.data!.docs; // Format the date

          return Container(
            // padding: EdgeInsets.all(10),
            child: ListView.builder(
                reverse: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  String message = documents[index].get('message');
                  String sender = documents[index].get('sender');
                  String address = documents[index].get('address');
                  DateTime date = documents[index]
                      .get('date')
                      .toDate(); // Retrieve the date and convert it to DateTime
                  String formattedDate =
                      DateFormat.yMMMd().add_jm().format(date);

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: Color.fromARGB(255, 48, 48, 53),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 218, 69, 67),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    text: 'Address: \n', // default text style
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: address,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 215, 145, 34),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  void clearMessages() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
      setState(() {
        documents = [];
      });
    });
  }

  void deleteAlert() {
    Alert(
      context: context,
      type: AlertType.warning,
      desc: "Tüm talepleri sileceğinizden emin misiniz?",
      buttons: [
        DialogButton(
          child: Text(
            "Evet",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            clearMessages();
            Navigator.pop(context);
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(124, 0, 0, 1),
            Color.fromRGBO(194, 2, 2, 1),
          ]),
        ),
        DialogButton(
          child: Text(
            "Hayır",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(2, 52, 158, 1),
            Color.fromRGBO(2, 29, 88, 1),
          ]),
        )
      ],
    ).show();
  }
}
