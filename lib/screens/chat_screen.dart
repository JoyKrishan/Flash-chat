import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  User loggedInUser;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    loggedInUser = user;
    if (loggedInUser != null) {
      print(loggedInUser.email);
    } else {
      print('Failed to get a user');
    }
  }

  // void getMessages()async{
  //   var messages = await _fireStore.collection('/messages').get();
  //   for (var message in messages.docs){
  //     print(message.data());
  //   }
  // }

  // void messageStream() async {
  //   await for (var snapshot in _fireStore.collection('/messages').snapshots()) {
  //     for (var messages in snapshot.docs) {
  //       print(messages.data()['text']);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pushNamed(context, LoginScreen.id);
                //messageStream();
                //getMessages();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _fireStore.collection('/messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  );
                }
                final messages = snapshot.data.docs.reversed;
                List<MessageBubble> msgBubble = [];
                for (var message in messages) {
                  String text = message.data()['text'];
                  String sender = message.data()['sender'];
                  msgBubble.add(
                    MessageBubble(sender: sender, messageText: text, isMe: sender == loggedInUser.email),
                  );
                }
                return Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    reverse: true,
                    children: msgBubble,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      if (messageText != null) {
                        _fireStore.collection('/messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                        });
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String messageText;
  final bool isMe;
  MessageBubble({this.sender, this.messageText, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isMe?CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.grey),
          ),
          Material(
            elevation: 5.0,
            color:isMe?Colors.lightBlueAccent: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              topLeft:isMe? Radius.circular(30.0): Radius.zero,
              bottomRight: Radius.circular(30.0),
              topRight: isMe== false? Radius.circular(30.0):Radius.zero,
              
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                messageText,
                style: TextStyle(color:isMe?Colors.white:Colors.black54, fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
