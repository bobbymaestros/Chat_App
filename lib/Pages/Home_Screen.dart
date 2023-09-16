import 'package:chat_app/Helpers/FirebaseHelper.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Pages/ChatRoom_Screen.dart';
import 'package:chat_app/Pages/Login_Screen.dart';
import 'package:chat_app/Pages/Search_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomeScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ));
                },
                icon: Icon(Icons.exit_to_app_sharp))
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Chat App')),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>,
                      );

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantkeys = participants.keys.toList();
                      participantkeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantkeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Dismissible(behavior: HitTestBehavior.opaque,
                                  key: Key(widget.firebaseUser.uid),
                                  // Unique key for each item
                                  background: Container(
                                    color: Colors.red.shade300,
                                    // Background color when swiping
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  // Swipe from right to left
                                  onDismissed: (direction) {
                                    // Handle deletion here, e.g., remove the chat room
                                    // FirebaseHelper.deleteChatRoom(chatRoomModel.id);

                                    // Show a snackbar to confirm deletion
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Deleted chat room with ${targetUser.fullname}'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () {
                                            // Undo the deletion logic if needed
                                            //  FirebaseHelper.undoDeleteChatRoom(chatRoomModel);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return ChatRoomScreen(
                                            targetUser: targetUser,
                                            chatroom: chatRoomModel,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseUser,
                                          );
                                        },
                                      ));
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          targetUser.profilepic.toString()),
                                    ),
                                    title: Text(targetUser.fullname.toString()),
                                    subtitle: Text(
                                        chatRoomModel.lastMessage.toString()),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchScreen(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser);
            },
          ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
