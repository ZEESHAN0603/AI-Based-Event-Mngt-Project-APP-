import 'package:flutter/material.dart';
import '../../widgets/synora_header.dart';

class IdeasBlogsScreen extends StatelessWidget {
  const IdeasBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SynoraHeader(
            title: 'Ideas & Blogs',
            subtitle: 'Get inspired for your next event',
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching latest event ideas and blogs...'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
