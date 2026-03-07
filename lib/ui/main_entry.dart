import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localia_provider.dart';
import 'tourist_screen.dart';
import 'admin_screen.dart';

class MainEntry extends StatelessWidget {
  const MainEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LocaliaProvider>(context);
    return state.isAdmin ? const AdminPortal() : const TouristPortal();
  }
}