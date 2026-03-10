import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/escolher_perfil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final TextEditingController emailValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SvgPicture.asset(
                  'assets/images/logo+nome.svg',
                  height: 90,
                  colorFilter: const ColorFilter.mode(
                    NeoGymColors.primary,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Bem-vindo",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16)
                  ),
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsetsGeometry.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailValue,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Digite seu e-mail",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: NeoGymColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                    
                        const SizedBox(height: 16),
                    
                        TextField(
                          controller: passValue,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "Digite sua senha",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: NeoGymColors.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: NeoGymColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                    
                        const SizedBox(height: 24),
                    
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NeoGymColors.primary,
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

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não possui conta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EscolherPerfil()),
                        );
                      },
                      child: const Text(
                        "Criar conta",
                        style: TextStyle(
                          color: NeoGymColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "ou entre com",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    InkWell(
                      onTap: () {
                        // login google
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset("assets/images/icons8-google.svg")
                      ),
                    ),

                    const SizedBox(width: 20),

                    InkWell(
                      onTap: () {
                        // login facebook
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset("assets/images/icons8-facebook-logo.svg")
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}