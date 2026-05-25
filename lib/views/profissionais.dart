import 'package:flutter/material.dart';
import 'package:neogym/Views/chat_screen.dart';
import 'package:neogym/Views/perfil_profissonal.dart';

import '../Resources/neo_gym_colors.dart';
import '../components/card_profissional.dart';
import '../models/professional.dart';

class Profissionais extends StatefulWidget {
  const Profissionais({super.key});

  @override
  State<Profissionais> createState() => _ProfissionaisState();
}

class _ProfissionaisState extends State<Profissionais> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = "Todos";
  String searchText = "";

  final List<Professional> professionalsList = professionals
      .map((e) => Professional.fromMap(e))
      .toList();

  @override
  Widget build(BuildContext context) {
    final filteredList = professionalsList.where((p) {
      final matchFilter = selectedFilter == "Todos" || p.type == selectedFilter;

      final matchSearch = p.name!.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      return matchFilter && matchSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildSearchBar(),

              const SizedBox(height: 20),

              buildFilters(),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final prof = filteredList[index];

                    return ProfessionalCard(
                      name: prof.name ?? "",
                      specialty: prof.specialty,
                      rating: prof.rating ?? 0,
                      distance: prof.distance,
                      imageUrl: prof.image ?? "",
                      isOnline: prof.isOnline ?? false,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfessionalDetailScreen(prof: prof),
                          ),
                        );
                      },

                      onChat: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(name: prof.name, Image: prof.image,),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Buscar profissional",
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

  Widget buildFilters() {
    final filters = ["Todos", "Personal", "Nutri"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: NeoGymColors.primary,
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }
}
