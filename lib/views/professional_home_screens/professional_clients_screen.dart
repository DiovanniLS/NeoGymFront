import 'package:flutter/material.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';

import '../../models/client_status.dart';
import 'client_details_screen.dart';

class ProfessionalClientsScreen extends StatefulWidget {
  const ProfessionalClientsScreen({super.key});

  @override
  State<ProfessionalClientsScreen> createState() =>
      _ProfessionalClientsScreenState();
}

class _ProfessionalClientsScreenState
    extends State<ProfessionalClientsScreen> {

  final TextEditingController searchController =
  TextEditingController();

  final List<ProfessionalClient> clients = [
    ProfessionalClient(
      id: 1,
      name: "Lucas Almeida",
      email: "lucas@email.com",
      status: ClientStatus.active,
      lastActivity: "Treino realizado hoje",
    ),
    ProfessionalClient(
      id: 2,
      name: "Ana Souza",
      email: "ana@email.com",
      status: ClientStatus.active,
      lastActivity: "Atendimento às 15:00",
    ),
    ProfessionalClient(
      id: 3,
      name: "Marcos Silva",
      email: "marcos@email.com",
      status: ClientStatus.pending,
      lastActivity: "Aguardando aprovação",
    ),
    ProfessionalClient(
      id: 4,
      name: "Juliana Santos",
      email: "juliana@email.com",
      status: ClientStatus.active,
      lastActivity: "Último treino há 2 dias",
    ),
  ];

  String search = "";

  List<ProfessionalClient> get filteredClients {
    if (search.trim().isEmpty) {
      return clients;
    }

    final text = search.toLowerCase().trim();

    return clients.where((client) {
      return client.name.toLowerCase().contains(text) ||
          client.email.toLowerCase().contains(text);
    }).toList();
  }

  int get activeClients {
    return clients
        .where(
          (client) =>
      client.status == ClientStatus.active,
    )
        .length;
  }

  int get pendingClients {
    return clients
        .where(
          (client) =>
      client.status == ClientStatus.pending,
    )
        .length;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Clientes",
      ),

      body: SafeArea(
        child: Column(
          children: [

            _buildSummary(),

            _buildSearch(),

            Expanded(
              child: filteredClients.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  20,
                ),
                itemCount:
                filteredClients.length,
                separatorBuilder: (_, __) =>
                const SizedBox(
                  height: 10,
                ),
                itemBuilder: (
                    context,
                    index,
                    ) {
                  final client =
                  filteredClients[index];

                  return _buildClientCard(
                    client,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [

          Expanded(
            child: _buildSummaryCard(
              title: "Ativos",
              value: activeClients.toString(),
              icon: Icons.people_outline,
              color: NeoGymColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _buildSummaryCard(
              title: "Pendentes",
              value: pendingClients.toString(),
              icon: Icons.schedule,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: TextField(
        controller: searchController,

        onChanged: (value) {
          setState(() {
            search = value;
          });
        },

        decoration: InputDecoration(
          hintText: "Buscar cliente...",

          prefixIcon:
          const Icon(Icons.search),

          suffixIcon:
          search.isNotEmpty
              ? IconButton(
            onPressed: () {
              searchController.clear();

              setState(() {
                search = "";
              });
            },
            icon:
            const Icon(Icons.close),
          )
              : null,

          filled: true,

          fillColor:
          Colors.grey.withOpacity(0.08),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide: BorderSide(
              color: NeoGymColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(
      ProfessionalClient client,
      ) {
    return Material(
      color: Colors.white,

      borderRadius:
      BorderRadius.circular(16),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),

        onTap: () {
          _openClient(client);
        },

        child: Container(
          padding:
          const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(16),

            border: Border.all(
              color:
              Colors.grey.shade200,
            ),
          ),

          child: Row(
            children: [

              CircleAvatar(
                radius: 27,

                backgroundColor:
                NeoGymColors.primary
                    .withOpacity(0.12),

                child: Text(
                  getInitials(
                    client.name,
                  ),
                  style: TextStyle(
                    color:
                    NeoGymColors.primary,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            client.name,
                            style:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        _buildStatus(
                          client.status,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      client.email,
                      style:
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [

                        const Icon(
                          Icons
                              .history,
                          size: 16,
                          color:
                          Colors.grey,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: Text(
                            client
                                .lastActivity,
                            style:
                            const TextStyle(
                              fontSize: 13,
                              color:
                              Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(
      ClientStatus status,
      ) {
    late String text;
    late Color color;

    switch (status) {
      case ClientStatus.active:
        text = "Ativo";
        color = Colors.green;
        break;

      case ClientStatus.pending:
        text = "Pendente";
        color = Colors.orange;
        break;

      case ClientStatus.inactive:
        text = "Inativo";
        color = Colors.grey;
        break;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [

            Icon(
              Icons.person_search_outlined,
              size: 75,
              color:
              Colors.grey.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              "Nenhum cliente encontrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              "Tente buscar por outro nome.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openClient(
      ProfessionalClient client,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ClientDetailsScreen(
              client: client,
            ),
      ),
    );
  }

  String getInitials(
      String name,
      ) {
    final parts = name
        .trim()
        .split(" ");

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return (
        parts.first[0] +
            parts.last[0]
    ).toUpperCase();
  }
}