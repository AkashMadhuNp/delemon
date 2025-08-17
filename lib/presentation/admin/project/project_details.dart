import 'package:flutter/material.dart';

class ProjectDetail extends StatefulWidget {
  const ProjectDetail({super.key});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projects Name"),
      ),


    );
  }
}