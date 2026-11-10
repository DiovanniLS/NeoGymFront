import 'package:flutter/material.dart';

import 'package:neogym/Views/messages_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/components/app_bottom_nav.dart';
import 'package:neogym/services/api_client.dart';
import 'package:neogym/views/student_home_screens/select_work_places.dart';
import 'package:provider/provider.dart';
import '../../Resources/neo_gym_colors.dart';
import '../../components/foto_perfil.dart';
import '../../components/nav_item.dart';
import '../../components/water_fill_card.dart';
import '../../models/gym.dart';
import '../../services/workout_service.dart';
import '../../view_model/agendamento_view_model.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/student_home_view_model.dart';
import '../../view_model/workout_view_model.dart';
import '../map_screen.dart';
import '../professional_home_screens/professional_clients_screen.dart';
import '../professional_home_screens/professional_home_content.dart';

enum AppTab { home, map, professionals, chat, settings }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  Gym? selectedGym;

  late List<Widget> studentPages;
  late List<Widget> professionalPages;

  bool _pagesInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_pagesInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Gym) {
      selectedGym = args;
    }

    studentPages = [
      const StudentHomeContent(),
      MapScreen(gym: selectedGym),
      const MessagesScreen(),
      const Profissionais(),
      const Configuracoes(),
    ];

    professionalPages = [
      const ProfessionalHomeContent(),
      const MessagesScreen(
        isProfessional: true,
      ),
      const SelectWorkPlaces(),
      const ProfessionalClientsScreen(),
      const Configuracoes(),
    ];

    _pagesInitialized = true;
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final studentNavItems = const [
    NavItem(
      icon: "assets/icons/botao-home.png",
      label: "Home",
    ),
    NavItem(
      icon: "assets/icons/localizacao.png",
      label: "Mapa",
    ),
    NavItem(
      icon: "assets/icons/chat.png",
      label: "Chat",
    ),
    NavItem(
      icon: "assets/icons/profissionais.png",
      label: "Profissionais",
    ),
    NavItem(
      icon: "assets/icons/configuracoes.png",
      label: "Config",
    ),
  ];

  final professionalNavItems = const [
    NavItem(
      icon: "assets/icons/botao-home.png",
      label: "Home",
    ),
    NavItem(
      icon: "assets/icons/chat.png",
      label: "Chat",
    ),
    NavItem(
      icon: "assets/icons/localizacao.png",
      label: "Locais",
    ),
    NavItem(
      icon: "assets/icons/profissionais.png",
      label: "Alunos",
    ),
    NavItem(
      icon: "assets/icons/configuracoes.png",
      label: "Config",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    final isProfessional =
        user?.tipo == "PERSONAL" || user?.tipo == "NUTRICIONISTA";

    final pages = isProfessional
        ? professionalPages
        : studentPages;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16,
        ),
        child: AppBottomNav(
          currentIndex: currentIndex,
          onTap: onTabTapped,
          items: isProfessional
              ? professionalNavItems
              : studentNavItems,
        ),
      ),
    );
  }
}

class StudentHomeContent extends StatelessWidget {
  const StudentHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthViewModel>().user;

    if (usuario == null) {
      return const Center(
        child: Text('Não há usuário autenticado.'),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentHomeViewModel(
            usuarioId: usuario.usuarioId,
          )..carregarDados(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutViewModel(
            WorkoutService(ApiClient.dio),
          )..carregarFichas(),
        ),
        ChangeNotifierProvider(
          create: (_) => AgendamentoViewModel()
            ..carregarAgendamentos(),
        ),
      ],
      child: const _StudentHomeContentView(),
    );
  }
}

class _StudentHomeContentView extends StatelessWidget {
  const _StudentHomeContentView();

  static const Color _azul = Color(0xFF3693B5);
  static const Color _turquesa = Color(0xFF36ACB5);
  static const Color _fundoCard = Color(0xFFF1F8FA);

  String _saudacao() {
    final hora = DateTime.now().hour;

    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _primeiroNome(String? nomeCompleto) {
    final nome = nomeCompleto?.trim() ?? '';

    if (nome.isEmpty) return 'Aluno';

    return nome.split(RegExp(r'\s+')).first;
  }

  Future<void> _atualizarTudo(
      StudentHomeViewModel hidratacao,
      WorkoutViewModel treinos,
      AgendamentoViewModel agenda,
      ) async {
    await Future.wait([
      hidratacao.carregarDados(),
      treinos.carregarFichas(),
      agenda.carregarAgendamentos(),
    ]);
  }

  void _abrirConfiguracaoHidratacao(
      BuildContext context,
      StudentHomeViewModel viewModel,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => _HydrationSettingsSheet(
        viewModel: viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hidratacao = context.watch<StudentHomeViewModel>();
    final treinos = context.watch<WorkoutViewModel>();
    final agenda = context.watch<AgendamentoViewModel>();
    final usuario = context.watch<AuthViewModel>().user;

    final nome = _primeiroNome(usuario?.nome);

    return SafeArea(
      child: RefreshIndicator(
        color: _azul,
        onRefresh: () => _atualizarTudo(
          hidratacao,
          treinos,
          agenda,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(nome),

              const SizedBox(height: 24),

              _buildWelcomeCard(context),

              const SizedBox(height: 24),

              const Text(
                'Seu dia em resumo',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Acompanhe sua rotina em um só lugar.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.fitness_center_rounded,
                      label: 'Fichas',
                      value: treinos.loading
                          ? '...'
                          : '${treinos.workouts.length}',
                      color: _azul,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'Agenda',
                      value: agenda.loading
                          ? '...'
                          : '${agenda.agendamentos.length}',
                      color: NeoGymColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Consumido',
                      value: hidratacao.loading
                          ? '...'
                          : _formatarAgua(hidratacao.currentWater),
                      color: _turquesa,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                title: 'Sua hidratação',
                subtitle: 'Mantenha sua meta diária em dia',
                icon: Icons.water_drop_rounded,
              ),

              const SizedBox(height: 12),

              if (hidratacao.loading)
                _buildLoadingCard('Carregando sua hidratação...')
              else if (hidratacao.errorMessage != null)
                _buildErrorCard(
                  mensagem: hidratacao.errorMessage!,
                  onRetry: hidratacao.carregarDados,
                )
              else
                WaterFillCard(
                  progress: hidratacao.waterProgress,
                  currentWater: hidratacao.currentWater,
                  goalWater: hidratacao.goalWater,
                  waterStepMl: hidratacao.waterStepMl,
                  onAddWater: hidratacao.adicionarAgua,
                  onSettings: () {
                    _abrirConfiguracaoHidratacao(
                      context,
                      hidratacao,
                    );
                  },
                ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                title: 'Seu treino',
                subtitle: 'Tudo pronto para sua próxima evolução',
                icon: Icons.fitness_center_rounded,
              ),

              const SizedBox(height: 12),

              _buildLinkedDataCard(
                title: 'Fichas de treino',
                subtitle: 'Seus planos de exercícios',
                icon: Icons.fitness_center_rounded,
                color: _azul,
                loading: treinos.loading,
                error: treinos.errorMessage,
                count: treinos.workouts.length,
                emptyMessage:
                'Você ainda não tem nenhuma ficha cadastrada.',
                countMessage: (count) => count == 1
                    ? 'Você tem 1 ficha de treino disponível.'
                    : 'Você tem $count fichas de treino disponíveis.',
                buttonText: 'Ver minhas fichas',
                onPressed: () {
                  Navigator.pushNamed(context, '/workouts');
                },
                onRetry: treinos.carregarFichas,
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                title: 'Sua agenda',
                subtitle: 'Organize seus compromissos',
                icon: Icons.calendar_month_rounded,
              ),

              const SizedBox(height: 12),

              _buildLinkedDataCard(
                title: 'Agendamentos',
                subtitle: 'Seus compromissos cadastrados',
                icon: Icons.event_available_rounded,
                color: NeoGymColors.primary,
                loading: agenda.loading,
                error: agenda.error,
                count: agenda.agendamentos.length,
                emptyMessage:
                'Você não tem agendamentos cadastrados.',
                countMessage: (count) => count == 1
                    ? 'Você tem 1 agendamento registrado.'
                    : 'Você tem $count agendamentos registrados.',
                buttonText: 'Ver minha agenda',
                onPressed: () {
                  Navigator.pushNamed(context, '/activities');
                },
                onRetry: agenda.carregarAgendamentos,
              ),

              const SizedBox(height: 22),

              Center(
                child: Text(
                  'Um passo de cada vez. Continue evoluindo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarAgua(double litros) {
    final ml = (litros * 1000).round();

    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)} L';
    }

    return '$ml ml';
  }

  Widget _buildHeader(String nome) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_saudacao()},',
                style: const TextStyle(
                  color: _azul,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Pronto para cuidar de você?',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _azul.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: const FotoPerfil(radius: 27),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_azul, _turquesa],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _azul.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'NEOGYM • SEU ESPAÇO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sua evolução começa hoje.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Treine com consistência e celebre cada conquista.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.93),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/workouts');
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                  label: const Text('Meu treino'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.fitness_center_rounded,
            size: 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _azul.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _azul,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedDataCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool loading,
    required String? error,
    required int count,
    required String emptyMessage,
    required String Function(int count) countMessage,
    required String buttonText,
    required VoidCallback onPressed,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _fundoCard,
              borderRadius: BorderRadius.circular(15),
            ),
            child: loading
                ? const Row(
              children: [
                SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Carregando informações...',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )
                : error != null
                ? Row(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: onRetry,
                  tooltip: 'Tentar novamente',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            )
                : Row(
              children: [
                Icon(
                  count == 0
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: color,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    count == 0
                        ? emptyMessage
                        : countMessage(count),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(buttonText),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard({
    required String mensagem,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tentar novamente',
          ),
        ],
      ),
    );
  }
}


class _HydrationSettingsSheet extends StatefulWidget {
  final StudentHomeViewModel viewModel;

  const _HydrationSettingsSheet({
    required this.viewModel,
  });

  @override
  State<_HydrationSettingsSheet> createState() =>
      _HydrationSettingsSheetState();
}

class _HydrationSettingsSheetState
    extends State<_HydrationSettingsSheet> {
  late double goal;
  late double step;

  final List<double> stepOptions = [
    0.1,
    0.2,
    0.3,
    0.5,
    0.75,
    1.0,
  ];

  @override
  void initState() {
    super.initState();

    goal = widget.viewModel.goalWater;
    step = widget.viewModel.waterStep;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurar hidratação',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Meta diária: '
                  '${goal.toStringAsFixed(1)} L',
            ),

            Slider(
              min: 1.0,
              max: 6.0,
              divisions: 50,
              value: goal,
              label:
              '${goal.toStringAsFixed(1)} L',
              onChanged: (value) {
                setState(() {
                  goal = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Text(
              'Quantidade por registro: '
                  '${(step * 1000).round()} ml',
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stepOptions.map((value) {
                final selecionado =
                    value == step;

                return ChoiceChip(
                  label: Text(
                    '${(value * 1000).round()} ml',
                  ),
                  selected: selecionado,
                  onSelected: (_) {
                    setState(() {
                      step = value;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.viewModel
                      .alterarMetaAgua(goal);

                  await widget.viewModel
                      .alterarQuantidadePorVez(step);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Salvar configurações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

