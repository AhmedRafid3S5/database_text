import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:database_text/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // To format the timestamp

class CommNotices extends StatefulWidget{
  const CommNotices({super.key});

  @override
  State<CommNotices> createState() => _CommNoticesState();
}

class _CommNoticesState extends State<CommNotices> {
  final TextEditingController textController = TextEditingController();
  final DatabaseService database = DatabaseService();

  //map for state of each button
  final Map<String, bool> isUpVotedMap = {};
  final Map<String, bool> isDownVotedMap = {};

  //
  final currentUser = "Rafid";

  //upVote and DownVote button states
   bool isUpVoted = false;
   bool isDownVoted = false;

  

  void openPostBox({String? messageId}){
      var buttonText = "Post";
      showDialog(
          
        context: context, 
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
            
          ),
          actions: [
            //button to save the message
            ElevatedButton(
              onPressed:(){
              
              if(messageId == null){
                buttonText = "Post";
                database.addMessage(textController.text);
                
              }
              //otherwise update the existing note
              else
              {
                 buttonText = "Update";
                 database.updateNote(messageId, textController.text);
              }
                //clear the field
                textController.clear();
                //close the box
                Navigator.pop(context);
              },
              child: Text(buttonText))
          ],
        ));
  }

  void toggleUpVote({messageId, required int currUpVotes, required int currDownVotes}){
    setState(() {
      
      isUpVotedMap[messageId] = !(isUpVotedMap[messageId] ?? false); // Toggle upvote

      if(isUpVotedMap[messageId] == true){
        //increment upVote and decrement downVote if it was on
        if(isDownVotedMap[messageId] == true && currDownVotes > 0)
        {
          database.updateVotes(messageId,DatabaseService.downVoteValDec);
        }
        isDownVotedMap[messageId] = false;
        database.updateVotes(messageId, DatabaseService.upVoteValInc);
      }
      else if (currUpVotes > 0){
        database.updateVotes(messageId, DatabaseService.upVoteValDec);
      }
    });
  }

  void toggleDownVote( {messageId, required int currUpVotes, required int currDownVotes}){
    setState(() {
      isDownVotedMap[messageId] = !(isDownVotedMap[messageId] ?? false); 
      if(isDownVotedMap[messageId] == true){
        
        if(isUpVotedMap[messageId]==true && currUpVotes > 0 ){
          database.updateVotes(messageId, DatabaseService.upVoteValDec);
        }
        isUpVotedMap[messageId] = false;
        database.updateVotes(messageId, DatabaseService.downVoteValInc);
      }
      else if (currDownVotes > 0){
        database.updateVotes(messageId, DatabaseService.downVoteValDec);
      }
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openPostBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: database.getMessagesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> messageList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                // get individual docs/messages
                DocumentSnapshot document = messageList[index];
                String messageId = document.id;

                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                 String messageTxt = data['message'] ?? 'No message'; // default value
                String userName = data['userName'] ?? 'Anonymous'; // default value
                Timestamp? timePosted = data['timePosted'] as Timestamp?;
                int upVotes = data['upVotes'] ?? 0; // default to 0 if null
                int downVotes = data['downVotes'] ?? 0; // default to 0 if null
                //bool states for individual messages
                  bool isUpVoted = isUpVotedMap[messageId] ?? false;
                  bool isDownVoted = isDownVotedMap[messageId] ?? false;
                // format the time, handle null case for timePosted
                String formattedTime = timePosted != null
                    ? DateFormat.yMMMd().add_jm().format(timePosted.toDate())
                    : 'Unknown time';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username and time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            // Spacer 
                            if(userName == currentUser)
                               IconButton(onPressed: () => openPostBox(messageId: messageId),
                                       icon: const Icon(Icons.update_outlined))
                            
                          ],
                          
                        ),
                        const SizedBox(height: 10),

                        // Message content
                        Text(
                          messageTxt,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 15),

                        // Upvote/Downvote counts and buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.thumb_up, size: 20),
                                    Text('$upVotes'),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    const Icon(Icons.thumb_down, size: 20),
                                    Text('$downVotes'),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Upvote button
                                ElevatedButton(
                                  onPressed:() => toggleUpVote(messageId: messageId,
                                                                  currDownVotes: downVotes,
                                                                  currUpVotes:upVotes ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUpVoted ? Colors.blue : Colors.grey, //Chng color based on state
                                  ),
                                  child: const Text("Upvote"),
                                ),
                                const SizedBox(width: 10),
                                // Downvote button
                                ElevatedButton(
                                  onPressed: () => toggleDownVote(messageId: messageId,
                                                                  currDownVotes: downVotes,
                                                                  currUpVotes:upVotes ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isDownVoted? Colors.red : Colors.grey),
                                  child: const Text("Downvote"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              
            );
          } else {
            return const Text("No messages");
          }
        },
      ),
    );
  }
}