import 'package:chat_app/Pages/ChatRoom_Screen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/v1.dart';

import '../Models/ChatRoomModel.dart';
import '../Models/UserModel.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch existing one
      var docData = snapshot.docs[0].data();

      ChatRoomModel existingChatroom =
      ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      //create a new one
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.alternate_email_sharp),
                  labelText: 'Email Address'),
            ),
            SizedBox(height: 20),
            CupertinoButton(
              child: Text('Search'),
              color: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
              onPressed: () {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot =
                    snapshot.data! as QuerySnapshot;

                    if (dataSnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel searchedUser = UserModel.fromMap(userMap);

                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatroomModel =
                          await getChatRoomModel(searchedUser);

                          if (chatroomModel != null) {
                            Navigator.pop(context);
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return ChatRoomScreen(targetUser: searchedUser,
                                  chatroom: chatroomModel,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser);
                            },));
                          }
                        },
                        leading: CircleAvatar(
                            backgroundImage:
                            NetworkImage(searchedUser.profilepic!),
                            backgroundColor: Colors.grey[500]),
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                        trailing: Icon(Icons.keyboard_arrow_right_sharp),
                      );
                    } else {
                      return Text("Search People's Via Email Adderss!!");
                    }
                  } else if (snapshot.hasError) {
                    return Text('An error occured!!');
                  } else {
                    return Text('No Result Found');
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
