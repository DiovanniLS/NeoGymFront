
import 'package:flutter/material.dart';
import 'package:neogym/views/professional_home_screens/galeria_profissional_screen.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/map_screen.dart';
import 'package:neogym/components/foto_perfil.dart';
import 'package:neogym/views/preferencias_screen.dart';
import 'package:neogym/views/reportar_problema_screen.dart';
import 'package:neogym/views/student_home_screens/home.dart';
import 'package:neogym/views/student_home_screens/lista_de_exerc%C3%ADcios.dart';

import '../view_model/auth_view_model.dart';
import 'ajuda_screen.dart';
import 'editar_perfil_screen.dart';
import 'meu_progresso_screen.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  bool _saindo = false;
  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().user;

    final tipo = usuario?.tipo.toString().toUpperCase() ?? '';

    final ehProfissional = tipo.contains('PERSONAL') ||
        tipo.contains('NUTRICIONISTA');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/home');
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildPerfilHeader(
                nome: usuario?.nome ?? 'Usuário',
                ehProfissional: ehProfissional,
              ),

              const SizedBox(height: 24),

              _buildBanner(ehProfissional),

              const SizedBox(height: 26),

              Text(
                ehProfissional
                    ? 'Área profissional'
                    : 'Minha conta',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: ehProfissional
                      ? _itensProfissional()
                      : _itensAluno(),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saindo ? null : _confirmarSaida,
                  icon: _saindo
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                      : const Icon(Icons.logout),
                  label: Text(
                    _saindo ? 'Encerrando sessão...' : 'Sair da conta',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _confirmarSaida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 32,
          ),
          title: const Text('Sair da conta?'),
          content: const Text(
            'Você precisará entrar novamente para acessar '
                'sua conta do NeoGym.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _saindo = true;
    });

    try {
      await context.read<AuthViewModel>().logout();

      if (!mounted) return;

      // Volta ao login e remove todas as telas anteriores.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
            (route) => false,
      );
    } catch (e) {
      debugPrint('Erro ao sair da conta: $e');

      if (!mounted) return;

      setState(() {
        _saindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível encerrar a sessão. Tente novamente.',
          ),
        ),
      );
    }
  }

  Widget _buildPerfilHeader({
    required String nome,
    required bool ehProfissional,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const FotoPerfil(radius: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ehProfissional
                    ? 'Perfil profissional'
                    : 'Rumo à sua melhor versão 💪',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color
                      ?.withOpacity(0.75),
                  fontSize: 13,
                ),
              ),
              if (ehProfissional) ...[
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: NeoGymColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Gerencie seus dados e atendimentos',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.75),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(bool ehProfissional) {
    if (ehProfissional) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NeoGymColors.primary,
              NeoGymColors.primary.withOpacity(0.78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: NeoGymColors.primary.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu espaço profissional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Mantenha seu perfil atualizado e '
                        'organize seus atendimentos.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF7A18),
            Color(0xFFFF3D00),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue sua jornada',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pequenos hábitos constroem grandes resultados.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _itensProfissional() {
    return [
      _buildItem(
        Icons.person_outline_rounded,
        'Editar perfil profissional',
        descricao: 'Dados pessoais e informações profissionais',
        onTap: _editarPerfil,
      ),

      _buildItem(
        Icons.photo_library_outlined,
        'Galeria profissional',
        descricao: 'Adicione e organize fotos do seu trabalho',
        pageBuilder: () => const GaleriaProfissionalScreen(),
      ),
      _buildItem(
        Icons.calendar_month_rounded,
        'Minha agenda',
        descricao: 'Consulte seus atendimentos',
        onTap: () async {
          await Navigator.pushNamed(context, '/agendaPro');
        },
      ),
      _buildItem(
        Icons.groups_rounded,
        'Meus alunos',
        descricao: 'Consulte alunos e gerencie seus treinos',
        onTap: () async {
          await Navigator.pushNamed(context, '/proClientScreen');
        },
      ),
      _buildItem(
        Icons.notifications_outlined,
        'Notificações',
        descricao: 'Avisos e atualizações',
        onTap: () async {
          _mostrarNotificacoes(context, ehProfissional: true);
        },
      ),
      _buildItem(
        Icons.tune_rounded,
        'Preferências',
        descricao: 'Personalize sua experiência',
        pageBuilder: () => const PreferenciasScreen(),
      ),
      _buildItem(
        Icons.help_outline_rounded,
        'Ajuda',
        descricao: 'Tire suas dúvidas',
        pageBuilder: () => const AjudaScreen(),
      ),
      _buildItem(
        Icons.bug_report_outlined,
        'Reportar problema',
        descricao: 'Informe um problema no aplicativo',
        pageBuilder: () => const ReportarProblemaScreen(),
      ),
    ];
  }

  List<Widget> _itensAluno() {
    return [
      _buildItem(
        Icons.person_outline_rounded,
        'Editar perfil',
        descricao: 'Atualize seus dados pessoais',
        onTap: _editarPerfil,
      ),
      _buildItem(
        Icons.bar_chart_rounded,
        'Meu progresso',
        descricao: 'Acompanhe sua evolução',
        pageBuilder: () => const MeuProgressoScreen(),
      ),
      _buildItem(
        Icons.fitness_center_rounded,
        'Minhas fichas',
        descricao: 'Consulte seus treinos',
        pageBuilder: () => const WorkoutListScreen(),
      ),
      _buildItem(
        Icons.location_on_outlined,
        'Minha academia',
        descricao: 'Consulte academias no mapa',
        pageBuilder: () => MapScreen(),
      ),
      _buildItem(
        Icons.water_drop_outlined,
        'Hidratação',
        descricao: 'Acompanhe sua hidratação diária',
        pageBuilder: () => HomeScreen(),
      ),
      _buildItem(
        Icons.notifications_outlined,
        'Notificações',
        descricao: 'Avisos e atualizações',
        onTap: () async {
          _mostrarNotificacoes(context, ehProfissional: false);
        },
      ),
      _buildItem(
        Icons.tune_rounded,
        'Preferências',
        descricao: 'Personalize sua experiência',
        pageBuilder: () => const PreferenciasScreen(),
      ),
      _buildItem(
        Icons.help_outline_rounded,
        'Ajuda',
        descricao: 'Tire suas dúvidas',
        pageBuilder: () => const AjudaScreen(),
      ),
      _buildItem(
        Icons.bug_report_outlined,
        'Reportar problema',
        descricao: 'Informe um problema no aplicativo',
        pageBuilder: () => const ReportarProblemaScreen(),
      ),
    ];
  }

  Future<void> _editarPerfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditarPerfilScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildItem(
      IconData icon,
      String title, {
        required String descricao,
        Widget Function()? pageBuilder,
        Future<void> Function()? onTap,
      }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (onTap != null) {
            await onTap();
            return;
          }

          if (pageBuilder != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => pageBuilder(),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NeoGymColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: NeoGymColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.70),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarNotificacoes(
      BuildContext context, {
        required bool ehProfissional,
      }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        if (ehProfissional) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Notificações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Suas notificações profissionais serão '
                        'exibidas aqui quando esse recurso estiver integrado.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 14),
                Text(
                  'Notificações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Suas notificações aparecerão aqui.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
