import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/cadastro_stepper.dart';

class EnvioDocumento extends StatelessWidget {

  final String nome;
  final String email;
  final String telefone;
  final String tipo;

  const EnvioDocumento({
    super.key,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.tipo,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("Validação de documento"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            CadastroStepper(step: 2),
            SizedBox(height: 30,),

            const Text(
              "Envie seus documentos para validação",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            uploadCard(
              icon: Icons.badge,
              title: "RG ou CNH",
              subtitle: "Foto do documento de identidade",
            ),

            const SizedBox(height: 20),

            uploadCard(
              icon: Icons.assignment_ind,
              title: tipo == 'Nutri' ? "Registro CRN" : 'Registro CREF',
              subtitle: tipo == 'Nutri' ? "Documento profissional do nutricionista" : "Documento profissional do personal trainer",
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoGymColors.primary,
                ),
                child: const Text("Finalizar cadastro"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16)
      ),
      elevation: 4,
      child: Container(
        padding: EdgeInsetsGeometry.all(16),
        child: Row(
          children: [
        
            Icon(
              icon,
              color: NeoGymColors.primary,
              size: 32,
            ),
        
            const SizedBox(width: 16),
        
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
        
                ],
              ),
            ),
        
            const Icon(Icons.upload_file)
        
          ],
        ),
      ),
    );
  }
}