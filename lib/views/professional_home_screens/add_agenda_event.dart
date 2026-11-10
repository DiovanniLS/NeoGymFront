import 'package:flutter/material.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/agenda_event.dart';
import 'package:neogym/models/client_status.dart';
import 'package:neogym/models/professional_client.dart';
import 'package:neogym/services/vinculo_service.dart';
import 'package:neogym/view_model/agendamento_view_model.dart';
import 'package:neogym/view_model/auth_view_model.dart';

import 'package:provider/provider.dart';

class AddAgendaEvent extends StatefulWidget {
  // Mantido para compatibilidade com os antigos pontos de navegação.
  // A API atual não possui endpoint para editar agendamentos.
  final AgendaEvent? event;

  const AddAgendaEvent({
    super.key,
    this.event,
  });

  @override
  State<AddAgendaEvent> createState() => _AddAgendaEventState();
}

class _AddAgendaEventState extends State<AddAgendaEvent> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  final VinculoService _vinculoService = VinculoService();

  List<ProfessionalClient> _alunos = [];
  ProfessionalClient? _alunoSelecionado;

  DateTime _dataSelecionada = DateTime.now().add(
    const Duration(hours: 1),
  );

  bool _carregandoAlunos = true;
  bool _salvando = false;
  String? _erroAlunos;

  bool get _modoLegado => widget.event != null;

  @override
  void initState() {
    super.initState();

    _carregarAlunos();

    if (widget.event != null) {
      _tituloController.text = widget.event!.title;
      _descricaoController.text = widget.event!.observation ?? '';
      _dataSelecionada = widget.event!.dateTime;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlunos() async {
    setState(() {
      _carregandoAlunos = true;
      _erroAlunos = null;
    });

    try {
      final resultado = await _vinculoService.buscarAlunosVinculados();

      if (!mounted) return;

      // O backend de criação do Personal exige vínculo ativo.
      final ativos = resultado
          .where((aluno) => aluno.status == ClientStatus.active)
          .toList()
        ..sort(
              (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );

      setState(() {
        _alunos = ativos;
        _carregandoAlunos = false;

        final nomeLegado = widget.event?.clientName;
        if (nomeLegado != null) {
          for (final aluno in ativos) {
            if (aluno.name == nomeLegado) {
              _alunoSelecionado = aluno;
              break;
            }
          }
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar alunos vinculados: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _carregandoAlunos = false;
        _erroAlunos = 'Não foi possível carregar os alunos vinculados.';
      });
    }
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    final inicial = _dataSelecionada.isBefore(hoje)
        ? hoje
        : _dataSelecionada;

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoje,
      lastDate: DateTime(2100),
    );

    if (data == null || !mounted) return;

    setState(() {
      _dataSelecionada = DateTime(
        data.year,
        data.month,
        data.day,
        _dataSelecionada.hour,
        _dataSelecionada.minute,
      );
    });
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataSelecionada),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (horario == null || !mounted) return;

    setState(() {
      _dataSelecionada = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        horario.hour,
        horario.minute,
      );
    });
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final selecionada = DateTime(data.year, data.month, data.day);

    if (selecionada == hoje) return 'Hoje';

    if (selecionada == hoje.add(const Duration(days: 1))) {
      return 'Amanhã';
    }

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHorario(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (_modoLegado) {
      _mostrarMensagem(
        'A edição ainda não está disponível na API de agendamentos.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final aluno = _alunoSelecionado;
    if (aluno == null) {
      _mostrarMensagem('Selecione um aluno.');
      return;
    }

    final usuario = context.read<AuthViewModel>().user;
    if (usuario == null) {
      _mostrarMensagem('Sua sessão expirou. Entre novamente.');
      return;
    }

    final tipo = usuario.tipo.toUpperCase();
    if (tipo != 'PERSONAL' && tipo != 'NUTRICIONISTA') {
      _mostrarMensagem(
        'Somente profissionais podem criar atendimentos nesta tela.',
      );
      return;
    }

    if (_dataSelecionada.isBefore(DateTime.now())) {
      _mostrarMensagem('Escolha uma data e horário futuros.');
      return;
    }

    setState(() => _salvando = true);

    try {
      await context.read<AgendamentoViewModel>().criarAgendamento(
        // Use o ID da tabela de aluno, não usuarioId.
        alunoId: aluno.id,
        tipoProfissional: tipo,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        dataHora: _dataSelecionada,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento criado com sucesso.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('Erro ao criar agendamento: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível criar o atendimento. ${_mensagemErro(e)}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String _mensagemErro(Object erro) {
    final texto = erro.toString();
    return texto.length > 180 ? 'Confira os dados e tente novamente.' : texto;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  InputDecoration _decoracao({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: NeoGymColors.primary,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: NeoGymColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _secao({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: NeoGymColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: NeoGymColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _seletorDataHorario({
    required String titulo,
    required String valor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: NeoGymColors.primary,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      valor,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UniversalAppBar(
        title: _modoLegado ? 'Editar atendimento' : 'Novo atendimento',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      NeoGymColors.primary,
                      NeoGymColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(height: 13),
                    Text(
                      'Agende um atendimento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Escolha o aluno, defina o horário e registre os detalhes.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (_modoLegado) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: NeoGymColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    'A edição de atendimentos existentes ainda não é suportada pelo backend.',
                  ),
                ),
              ],

              const SizedBox(height: 20),

              _secao(
                titulo: 'Informações',
                subtitulo: 'Selecione o aluno e descreva o atendimento',
                icon: Icons.assignment_outlined,
                children: [
                  if (_carregandoAlunos)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_erroAlunos != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_erroAlunos!),
                        TextButton.icon(
                          onPressed: _carregarAlunos,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  else if (_alunos.isEmpty)
                      const Text(
                        'Nenhum aluno com vínculo ativo foi encontrado. '
                            'Verifique seus vínculos antes de agendar.',
                      )
                    else
                      DropdownButtonFormField<ProfessionalClient>(
                        value: _alunoSelecionado,
                        isExpanded: true,
                        decoration: _decoracao(
                          label: 'Aluno',
                          icon: Icons.person_outline_rounded,
                        ),
                        items: _alunos.map((aluno) {
                          return DropdownMenuItem<ProfessionalClient>(
                            value: aluno,
                            child: Text(
                              aluno.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        validator: (value) =>
                        value == null ? 'Selecione um aluno.' : null,
                        onChanged: _modoLegado
                            ? null
                            : (value) {
                          setState(() {
                            _alunoSelecionado = value;
                          });
                        },
                      ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _tituloController,
                    enabled: !_modoLegado,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoracao(
                      label: 'Título do atendimento',
                      hint: 'Ex.: Treino de superiores',
                      icon: Icons.edit_note_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o título do atendimento.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _descricaoController,
                    enabled: !_modoLegado,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoracao(
                      label: 'Descrição (opcional)',
                      hint: 'Observações sobre o atendimento',
                      icon: Icons.notes_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              _secao(
                titulo: 'Data e horário',
                subtitulo: 'Defina quando acontecerá',
                icon: Icons.schedule_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _seletorDataHorario(
                          titulo: 'Data',
                          valor: _formatarData(_dataSelecionada),
                          icon: Icons.calendar_today_rounded,
                          onTap: _modoLegado ? () {} : _selecionarData,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: _seletorDataHorario(
                          titulo: 'Horário',
                          valor: _formatarHorario(_dataSelecionada),
                          icon: Icons.access_time_rounded,
                          onTap: _modoLegado ? () {} : _selecionarHorario,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _salvando ||
                      _carregandoAlunos ||
                      _erroAlunos != null ||
                      _alunos.isEmpty ||
                      _modoLegado
                      ? null
                      : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _salvando ? 'Salvando...' : 'Criar atendimento',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: NeoGymColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
}