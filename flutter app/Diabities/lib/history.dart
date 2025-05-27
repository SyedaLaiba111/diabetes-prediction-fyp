import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Prediction History"),
          backgroundColor: Colors.teal[700],
        ),
        body: Center(
          child: Text(
            "Please log in to view your history.",
            style: TextStyle(fontSize: 18, color: Colors.teal[900]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Prediction History"),
        backgroundColor: Colors.teal[700],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade100, Colors.teal.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('predictions')
                .where('uid', isEqualTo: user.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Something went wrong!',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.teal[700]));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No predictions yet.',
                    style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                  ),
                );
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final date = (data['timestamp'] as Timestamp?)?.toDate();
                  final formattedDate = date != null
                      ? DateFormat.yMMMd().add_jm().format(date)
                      : 'Unknown date';

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadowColor: Colors.tealAccent.withOpacity(0.4),
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      title: Text(
                        data['result'] ?? 'Result unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal[900],
                        ),
                      ),
                      subtitle: Text(
                        'Date: $formattedDate',
                        style: TextStyle(color: Colors.teal[700]),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Prediction Details"),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: data.entries.map((entry) {
                                  return Text("${entry.key}: ${entry.value}");
                                }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close', style: TextStyle(color: Colors.teal[700])),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
