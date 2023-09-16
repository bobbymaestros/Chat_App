class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? type;

  MessageModel({this.sender,this.text,this.seen,this.createdon, this.messageid, required String type});

  MessageModel.fromMap(Map<String, dynamic> map){
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    messageid = map["messageid"];
    type = map["type"];
  }

  Map<String,dynamic> toMap(){
    return{
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "messageid": messageid,
      "type" : type,
    };
  }
}