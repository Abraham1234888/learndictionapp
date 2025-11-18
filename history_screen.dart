import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation History')),
      body: history.isEmpty
          ? const Center(child: Text('No history yet.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(item['phrase']),
                  subtitle: Text('You said: ${item['spoken']}'),
                  trailing: Text(
                    '${(item['score'] * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: item['score'] >= 0.9
                          ? Colors.green
                          : item['score'] >= 0.7
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
