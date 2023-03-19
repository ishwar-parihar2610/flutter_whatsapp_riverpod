import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';

import '../controller/select_contact_controller.dart';

class SelecContactScreen extends ConsumerWidget {
  const SelecContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: Text("Select Contact"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),
      body: ref.watch(getContactProvider).when(
        data: (contactList) {
          return ListView.builder(
            itemCount: contactList.length,
            itemBuilder: (context, index) {
              final contact = contactList[index];
              return Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 8),
                child: ListTile(
                  title: Text(contact.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    
                  ),),
                  leading: contact.photo==null? null:CircleAvatar(
                    backgroundImage: MemoryImage(contact.photo!),
                    radius: 30,
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
        loading: () {
          return CircularProgressIndicator.adaptive();
        },
      ),
    );
  }
}
