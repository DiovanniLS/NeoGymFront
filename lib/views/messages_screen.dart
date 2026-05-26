import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Resources/neo_gym_colors.dart';
import '../components/chat_card.dart';
import '../models/professional.dart';
import '../view_model/professional_viewmodel.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ProfessionalViewModel>().loadProfessionals();
    });
  }

  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfessionalViewModel>();

    final filteredList = vm.professionals.where((p) {
      final matchSearch = p.name!.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      return matchSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildSearchBar(),

            const SizedBox(height: 10),

            Expanded(
              child:
              ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final prof = filteredList[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChatCard(
                      name: prof.name,
                      imageUrl: prof.image,
                      lastMessage: "Toque para conversar...",
                      time: "12:30",
                      isOnline: prof.isOnline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              name: prof.name,
                              Image: prof.image,
                              chatId: 'chat_${prof.id}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Buscar Conversas..",
          prefixIcon: Icon(Icons.search, color: NeoGymColors.primary),
          suffixIcon: IconButton(
            onPressed: () {
              searchController.clear();
              setState(() {
                searchText = "";
              });
            },
            icon: Icon(Icons.cancel, color: NeoGymColors.primary),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
