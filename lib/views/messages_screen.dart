import 'package:flutter/material.dart';

import '../Resources/neo_gym_colors.dart';
import '../components/chat_card.dart';
import '../models/professional.dart';
import '../models/professional_client.dart';
import '../services/vinculo_service.dart';
import '../storage/token_storage.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final bool isProfessional;

  const MessagesScreen({
    super.key,
    this.isProfessional = false,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController searchController = TextEditingController();
  final VinculoService _vinculoService = VinculoService();

  String searchText = "";

  List<ProfessionalClient> students = [];

  List<Professional> professionals = [];
  bool loadingProfessionals = false;
  String? professionalsError;

  bool loadingStudents = false;
  String? studentsError;

  int? usuarioLogadoId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final id = await TokenStorage.getUserId();

      if (!mounted) return;

      setState(() {
        usuarioLogadoId = id;
      });

      if (widget.isProfessional) {
        _loadStudents();
      } else {
        _loadLinkedProfessionals();
      }
    });
  }

  Future<void> _loadLinkedProfessionals() async {
    setState(() {
      loadingProfessionals = true;
      professionalsError = null;
    });

    try {
      final result =
      await _vinculoService.buscarProfissionaisVinculados();

      if (!mounted) return;

      setState(() {
        professionals = result;
        loadingProfessionals = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        professionalsError =
        'Não foi possível carregar os Personais vinculados.';
        loadingProfessionals = false;
      });
    }
  }

  Future<void> _loadStudents() async {
    setState(() {
      loadingStudents = true;
      studentsError = null;
    });

    try {
      final result = await _vinculoService.buscarAlunosVinculados();

      if (!mounted) return;

      setState(() {
        students = result;
        loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        studentsError = 'Não foi possível carregar os alunos.';
        loadingStudents = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (usuarioLogadoId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            buildSearchBar(),

            const SizedBox(height: 10),

            Expanded(
              child: widget.isProfessional
                  ? _buildStudentsList()
                  : _buildProfessionalsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalsList() {
    if (loadingProfessionals) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (professionalsError != null) {
      return Center(
        child: Text(professionalsError!),
      );
    }

    final filteredList = professionals.where((professional) {
      return professional.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum Personal vinculado.',
        ),
      );
    }

    return ListView.builder(
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
                    chatId: _gerarChatId(
                      usuarioLogadoId!,
                      prof.usuarioId,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentsList() {
    if (loadingStudents) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (studentsError != null) {
      return Center(
        child: Text(studentsError!),
      );
    }

    final filteredList = students.where((student) {
      return student.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum aluno vinculado.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final student = filteredList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ChatCard(
            name: student.name,
            imageUrl: '',
            lastMessage: "Toque para conversar...",
            time: "12:30",
            isOnline: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    name: student.name,
                    Image: '',
                    chatId: _gerarChatId(
                      usuarioLogadoId!,
                      student.usuarioId,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _gerarChatId(int usuarioA, int usuarioB) {
    final ids = [usuarioA, usuarioB]..sort();

    return 'chat_${ids[0]}_${ids[1]}';
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
          prefixIcon: Icon(
            Icons.search,
            color: NeoGymColors.primary,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              searchController.clear();

              setState(() {
                searchText = "";
              });
            },
            icon: Icon(
              Icons.cancel,
              color: NeoGymColors.primary,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }
}