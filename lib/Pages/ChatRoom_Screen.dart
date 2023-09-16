import 'dart:developer';
import 'dart:io';

import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  TextEditingController emojiController = TextEditingController();
  bool show = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(() {
      if(focusNode.hasFocus){
        setState(() {
          show = false;
        });
      }
    });
  }
  File? imageFile;

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
          type: "text",
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

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadingImage();
      }
    });
  }

  Future uploadingImage() async {
    String fileName = uuid.v1();
    var ref =
        FirebaseStorage.instance.ref().child('image').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);

    String ImageUrl = await uploadTask.ref.getDownloadURL();
    print(ImageUrl);
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
      body: WillPopScope(
        child: Stack(
          children: [
            Image.asset(
              "assets/images/BGIMG.jpg",
              fit: BoxFit.cover,
              width: 450,
            ),
            Container(
              // height: 450,
              decoration: BoxDecoration(),
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

                    Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(color: Colors.white),
                            padding:
                                EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Row(
                              children: [
                                Flexible(
                                    child: TextField(
                                      focusNode: focusNode,
                                  maxLines: null,
                                  controller: messageController,
                                  decoration: InputDecoration(
                                      hintText: 'Enter message',
                                      prefixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              focusNode.unfocus();
                                              focusNode.canRequestFocus = false;
                                              show = !show;
                                            });
                                          },
                                          icon: Icon(CupertinoIcons.smiley)),
                                      suffixIcon: IconButton(
                                        icon: Icon(CupertinoIcons.photo),
                                        onPressed: () {
                                          getImage();
                                        },
                                      ),
                                      border: InputBorder.none),
                                )),
                                IconButton(
                                    onPressed: () {
                                      sendMessage();
                                    },
                                    icon: Icon(
                                      Icons.send,
                                      color:
                                          Theme.of(context).colorScheme.secondary,
                                    )),
                              ],
                            )),
                        show
                            ? Offstage(
                                offstage: false,
                                child: SizedBox(
                                    height: 250,
                                    child: EmojiPicker(
                                      onEmojiSelected: (category, emoji) {
                                        setState(() {
                                          emojiController.text = emojiController.text+ emoji.emoji;
                                        });
                                      },
                                      onBackspacePressed: () {},
                                      config: Config(
                                        columns: 7,
                                        emojiSizeMax: 32,
                                        verticalSpacing: 0,
                                        horizontalSpacing: 0,
                                        gridPadding: EdgeInsets.zero,
                                        initCategory: Category.RECENT,
                                        bgColor: Color(0xFFF2F2F2),
                                        indicatorColor: Colors.blue,
                                        iconColor: Colors.grey,
                                        iconColorSelected: Colors.blue,
                                        backspaceColor: Colors.blue,
                                        skinToneDialogBgColor: Colors.white,
                                        skinToneIndicatorColor: Colors.grey,
                                        enableSkinTones: true,
                                        recentTabBehavior:
                                            RecentTabBehavior.RECENT,
                                        recentsLimit: 28,
                                        noRecents: const Text(
                                          'No Recents',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black26),
                                          textAlign: TextAlign.center,
                                        ),
                                        // Needs to be const Widget
                                        loadingIndicator: const SizedBox.shrink(),
                                        // Needs to be const Widget
                                        tabIndicatorAnimDuration:
                                            kTabScrollDuration,
                                        categoryIcons: const CategoryIcons(),
                                        buttonMode: ButtonMode.MATERIAL,
                                      ),
                                    )),
                              )
                            : Container(),
                      ],
                    ),
                  ]),
                ),
              ),
            )
          ],
        ),
        onWillPop: () {
          if(show){
            setState(() {
              show = false;
            });
          }else{
            Navigator.pop(context);
          }
          return Future.value(false);
        },
      ),
    );
  }
}
