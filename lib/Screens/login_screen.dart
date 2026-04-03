
import 'package:fase_1/Screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp",
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 160, 19, 66),
        body: SafeArea(
          child:SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,//probablemente innecesario
              children: [
                Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 30)),//para hacer espacio
                const SizedBox(height: 90),
                //icono de inicio de sesion provicional
                const Icon(Icons.verified_user, size: 80,color:Color.fromARGB(255, 39, 37, 37)),
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    "Iniciar Sesion",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF)))
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      children: [
                        //introducir el correo electronico
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),//color de fondo blanco
                            hintText: "Correo Electronico",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none)
                              )
                            ),
                        SizedBox(height: 20,),
                        //introducir la contrase;a
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffffffff),//igual fondo blanco
                            hintText: "Contraseña",
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: Icon(Icons.remove_red_eye),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            )
                          ),
                        ),
                        SizedBox(height: 20,),
                        //Boton de inicio de sesion
                        ElevatedButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(15)
                          )
                        ),
                         child: Text(
                          "Iniciar sesion",
                          style: TextStyle(
                            fontSize: 26,
                            color: Color.fromARGB(255, 184, 10, 10)
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No tienes una cuenta?",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 15
                          ),
                        ),
                        TextButton(onPressed: (){}, child: Text("Registrate",
                        style: TextStyle(
                          color: Color.fromARGB(255, 222, 205, 14)
                              ),
                            )
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        ),
      );
  }
}