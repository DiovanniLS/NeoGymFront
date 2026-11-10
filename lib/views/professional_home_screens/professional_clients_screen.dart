import 'package:flutter/material.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/components/foto_usuario.dart';

import '../../models/client_status.dart';
import '../../models/professional_client.dart';
import '../../services/vinculo_service.dart';
import 'client_details_screen.dart';

class ProfessionalClientsScreen extends StatefulWidget {
  const ProfessionalClientsScreen({super.key});

  @override
  State<ProfessionalClientsScreen> createState() =>
      _ProfessionalClientsScreenState();
}

class _ProfessionalClientsScreenState
    extends State<ProfessionalClientsScreen> {
  final TextEditingController searchController = TextEditingController();
  final VinculoService _vinculoService = VinculoService();

  List<ProfessionalClient> clients = [];

  bool _loading = true;
  String? _error;
  String search = '';
  ClientStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final resultado =
      await _vinculoService.buscarAlunosVinculados();

      if (!mounted) return;

      setState(() {
        clients = resultado;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os clientes.';
      });
    }
  }

  List<ProfessionalClient> get filteredClients {
    final texto = search.trim().toLowerCase();

    return clients.where((client) {
      final correspondeTexto = texto.isEmpty ||
          client.name.toLowerCase().contains(texto) ||
          client.email.toLowerCase().contains(texto);

      final correspondeStatus = _selectedFilter == null ||
          client.status == _selectedFilter;

      return correspondeTexto && correspondeStatus;
    }).toList();
  }

  int get activeClients => clients
      .where((client) => client.status == ClientStatus.active)
      .length;

  int get pendingClients => clients
      .where((client) => client.status == ClientStatus.pending)
      .length;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const UniversalAppBar(
        title: 'Meus alunos',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildIntro(),
            _buildSummary(),
            _buildSearch(),
            _buildFilters(),
            Expanded(
              child: RefreshIndicator(
                color: NeoGymColors.primary,
                onRefresh: _carregarClientes,
                child: _buildClientsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sua equipe',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Gerencie seus alunos e acompanhe os vínculos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: NeoGymColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  _loading ? '—' : '${clients.length}',
                  style: const TextStyle(
                    color: NeoGymColors.primary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Alunos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Ativos',
              value: _loading ? '—' : '$activeClients',
              subtitle: 'Vínculos ativos',
              icon: Icons.check_circle_outline_rounded,
              color: NeoGymColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Pendentes',
              value: _loading ? '—' : '$pendingClients',
              subtitle: 'Aguardando vínculo',
              icon: Icons.schedule_rounded,
              color: NeoGymColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline
              .withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 13),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou e-mail',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.48),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: NeoGymColors.primary,
          ),
          suffixIcon: search.isNotEmpty
              ? IconButton(
            tooltip: 'Limpar pesquisa',
            onPressed: () {
              searchController.clear();
              setState(() {
                search = '';
              });
            },
            icon: const Icon(Icons.close_rounded),
          )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: theme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: theme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: NeoGymColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {

    return SizedBox(
      height: 46,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'Todos',
            selected: _selectedFilter == null,
            onSelected: () => _selecionarFiltro(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Ativos',
            selected: _selectedFilter == ClientStatus.active,
            onSelected: () =>
                _selecionarFiltro(ClientStatus.active),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Pendentes',
            selected: _selectedFilter == ClientStatus.pending,
            onSelected: () =>
                _selecionarFiltro(ClientStatus.pending),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Inativos',
            selected: _selectedFilter == ClientStatus.inactive,
            onSelected: () =>
                _selecionarFiltro(ClientStatus.inactive),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      label: Text(label),
      labelStyle: TextStyle(
        color: selected
            ? NeoGymColors.primary
            : theme.colorScheme.onSurface
            .withValues(alpha: 0.75),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: NeoGymColors.primary.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected
            ? NeoGymColors.primary.withValues(alpha: 0.4)
            : theme.colorScheme.outline
            .withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
    );
  }

  void _selecionarFiltro(ClientStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
  }

  Widget _buildClientsList() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Center(
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 18),
          Center(
            child: Text('Carregando seus alunos...'),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: 300,
            child: _buildErrorState(),
          ),
        ],
      );
    }

    final resultado = filteredClients;

    if (resultado.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: 300,
            child: _buildEmptyState(),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 28),
      itemCount: resultado.length,
      separatorBuilder: (_, __) => const SizedBox(height: 11),
      itemBuilder: (context, index) {
        return _buildClientCard(resultado[index]);
      },
    );
  }

  Widget _buildClientCard(ProfessionalClient client) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openClient(client),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline
                  .withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NeoGymColors.primary
                        .withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: FotoUsuario(
                  key: ValueKey(client.usuarioId),
                  usuarioId: client.usuarioId,
                  width: 54,
                  height: 54,
                  borderRadius: 1000,
                  iconSize: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.62),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 15,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            client.lastActivity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatus(client.status),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(ClientStatus status) {
    final theme = Theme.of(context);

    late final String texto;
    late final Color cor;

    switch (status) {
      case ClientStatus.active:
        texto = 'Ativo';
        cor = NeoGymColors.success;
        break;

      case ClientStatus.pending:
        texto = 'Pendente';
        cor = NeoGymColors.warning;
        break;

      case ClientStatus.inactive:
        texto = 'Inativo';
        cor = theme.colorScheme.onSurface
            .withValues(alpha: 0.6);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cor.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 58,
          color: theme.colorScheme.onSurface
              .withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        Text(
          'Não foi possível carregar os clientes',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verifique sua conexão e tente novamente.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _carregarClientes,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final temFiltros = search.trim().isNotEmpty ||
        _selectedFilter != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: NeoGymColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_search_rounded,
            size: 38,
            color: NeoGymColors.primary,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          temFiltros
              ? 'Nenhum resultado encontrado'
              : 'Você ainda não tem alunos',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          temFiltros
              ? 'Tente outro nome ou altere o filtro selecionado.'
              : 'Quando houver alunos vinculados, eles aparecerão aqui.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
        if (temFiltros) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              searchController.clear();
              setState(() {
                search = '';
                _selectedFilter = null;
              });
            },
            icon: const Icon(Icons.filter_alt_off_rounded),
            label: const Text('Limpar filtros'),
          ),
        ],
      ],
    );
  }

  void _openClient(ProfessionalClient client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailsScreen(
          client: client,
        ),
      ),
    );
  }
}