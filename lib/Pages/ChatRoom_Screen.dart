import 'dart:developer';

import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomScreen(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg.isNotEmpty) {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString())),
          SizedBox(width: 10),
          Text(widget.targetUser.fullname.toString())
        ],
      )),
      body: Stack(
        children: [
          Image.asset("assets/images/BGIMG.jpg",fit:BoxFit.cover,width: 450,),
          Container(
            // height: 450,
            decoration: BoxDecoration(

            ),
            child: SafeArea(
              child: Container(
                child: Column(children: [
                  // this is where the chat will go
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("chatrooms")
                            .doc(widget.chatroom.chatroomid)
                            .collection("messages")
                            .orderBy("createdon", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData) {
                              QuerySnapshot dataSnapshot =
                                  snapshot.data as QuerySnapshot;

                              return ListView.builder(
                                reverse: true,
                                itemCount: dataSnapshot.docs.length,
                                itemBuilder: (context, index) {
                                  MessageModel currentMessage =
                                      MessageModel.fromMap(
                                          dataSnapshot.docs[index].data()
                                              as Map<String, dynamic>);

                                  return Row(
                                    mainAxisAlignment: (currentMessage.sender ==
                                            widget.userModel.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            currentMessage.text.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )),
                                    ],
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    "An error occured! Please check your internet connection."),
                              );
                            } else {
                              return Center(
                                child: Text("Say hi to your new friend"),
                              );
                            }
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          Flexible(
                              child: TextField(
                            maxLines: null,
                            controller: messageController,
                            decoration: InputDecoration(
                                hintText: 'Enter message',
                                border: InputBorder.none),
                          )),
                          IconButton(
                              onPressed: () {
                                sendMessage();
                              },
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.secondary,
                              ))
                        ],
                      )),
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }
}
