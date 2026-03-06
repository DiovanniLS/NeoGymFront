import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool rememberPass = false;
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.menu))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/logo_NG.svg',
                colorFilter: const ColorFilter.mode(
                    Color(0xFFFF6B00), BlendMode.srcIn)
                ,),
              Container(
                margin: EdgeInsets.only(top: 150),
                child: TextField(
                  controller: emailValue,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Digite seu e-mail",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextField(
                obscureText: !isPasswordVisible,
                controller: passValue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Digite sua senha",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: NeoGymColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              TextField(
                obscureText: !isPasswordVisible,
                controller: passValue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Repita sua senha",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: NeoGymColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Lembrar senha',
                  style: TextStyle(fontSize: 16),
                ),
                value: rememberPass,
                onChanged: (bool? value) {
                  setState(() {
                    rememberPass = value ?? false;
                  });
                },
                activeColor: NeoGymColors.primary, // cor do quadrado marcado
                checkColor: Colors.white, // cor do tick
                side: const BorderSide(color: NeoGymColors.primary, width: 2), // borda não marcada
                controlAffinity: ListTileControlAffinity.leading, // checkbox à esquerda
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Entrar",
                    style: TextStyle(fontSize: 16),
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
