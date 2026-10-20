import 'package:flutter/material.dart';

import 'package:neogym/Views/messages_screen.dart';
import 'package:neogym/Views/configuracoes.dart';
import 'package:neogym/Views/profissionais.dart';
import 'package:neogym/components/app_bottom_nav.dart';
import 'package:neogym/components/card_principal.dart';
import 'package:neogym/views/student_home_screens/select_work_places.dart';
import 'package:provider/provider.dart';
import '../../components/foto_perfil.dart';
import '../../components/nav_item.dart';
import '../../components/water_fill_card.dart';
import '../../models/gym.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/student_home_view_model.dart';
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
      label: "Mapa",
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
    return ChangeNotifierProvider(
      create: (context) {
        final usuario =
            context.read<AuthViewModel>().user;

        if (usuario == null) {
          throw StateError(
            'Não há usuário autenticado para carregar a hidratação.',
          );
        }

        return StudentHomeViewModel(
          usuarioId: usuario.usuarioId,
        )..carregarDados();
      },
      child: const _StudentHomeContentView(),
    );
  }
}
class _StudentHomeContentView extends StatelessWidget {
  const _StudentHomeContentView();

  String _formatarLitros(double litros) {
    if (litros <= 0) {
      return '0ml';
    }

    final ml = (litros * 1000).round();

    if (ml < 1000) {
      return '${ml}ml';
    }

    return '${litros.toStringAsFixed(1)}L';
  }

  void _abrirConfiguracaoHidratacao(
      BuildContext context,
      StudentHomeViewModel viewModel,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return _HydrationSettingsSheet(
          viewModel: viewModel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentHomeViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    if (viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: viewModel.carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final nome = authViewModel.user?.nome ?? 'Aluno';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(nome),
            const SizedBox(height: 30),
            _buildHydrationCard(context, viewModel),
            const SizedBox(height: 30),
            _buildWorkoutCard(context),
            const SizedBox(height: 30),
            _buildClassesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      String nome,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $nome 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'vamos treinar hoje?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        const FotoPerfil(
          radius: 28,
        ),
      ],
    );
  }

  Widget _buildHydrationCard(
      BuildContext context,
      StudentHomeViewModel viewModel,
      ) {
    return WaterFillCard(
      progress: viewModel.waterProgress,
      currentWater: viewModel.currentWater,
      goalWater: viewModel.goalWater,
      waterStepMl: viewModel.waterStepMl,
      onAddWater: viewModel.adicionarAgua,
      onSettings: () {
        _abrirConfiguracaoHidratacao(
          context,
          viewModel,
        );
      },
    );
  }

  Widget _buildWorkoutCard(BuildContext context) {
    return CardPrincipal(
      leading: Image.asset('assets/icons/treino.png'),
      title: 'Ficha de Treino',
      content: Row(
        children: [
          Image.asset(
            'assets/icons/gym_illustration.png',
            width: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peito + Tríceps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '5 Exercícios',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/workouts');
        },
        child: const Text('Ver Ficha'),
      ),
    );
  }

  Widget _buildClassesCard(BuildContext context) {
    return CardPrincipal(
      leading: const Icon(
        Icons.calendar_today,
        color: Colors.orange,
      ),
      title: 'Próximas Aulas',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[200]),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Funcional'),
              Text('18:00'),
            ],
          ),

          const SizedBox(height: 6),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Musculação'),
              Text('20:00'),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Hoje você tem 2 atividades',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/activities');
        },
        child: const Text('Ver Agenda'),
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

