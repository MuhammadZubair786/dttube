import 'package:dttube/utils/color.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  final List<ChatItem> chats = [
    ChatItem('John Doe', 'Hey, how are you?', '12:30 PM', 'assets/avatar1.png'),
    ChatItem('Jane Smith', 'Let\'s meet tomorrow.', '11:15 AM', 'assets/images/ic_intro1.png'),
    ChatItem('Alice Johnson', 'Check out this photo!', '10:45 AM', 'assets/images/ic_intro2.png'),
    ChatItem('Bob Martin', 'Where are you?', 'Yesterday', 'assets/images/ic_intro3.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Chats',style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ChatTile(chatItem: chats[index]);
        },
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;

  ChatItem(this.name, this.lastMessage, this.time, this.avatar);
}

class ChatTile extends StatelessWidget {
  final ChatItem chatItem;

  ChatTile({required this.chatItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(chatItem.avatar),
      ),
      title: Text(
        chatItem.name,
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
      ),
      subtitle: Text(chatItem.lastMessage, style: TextStyle(color: Colors.white),),
      trailing: Text(
        chatItem.time,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        // Handle chat tap
      },
    );
  }
}