// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables
// ignore: prefer_const_constructor

import 'package:flutter/material.dart';
import 'package:srm_app_client_app/constants.dart';
import '../../widgets/app_title.dart';

class ErrorScreen extends StatelessWidget {
  static String routeName = '/error';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: 500,
              ),
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Wrap(
                  runSpacing: 20,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Image.asset('assets/images/icon-no-wifi.png'),
                      ],
                    ), 
                    SizedBox(
                        width: double.infinity,
                        child: AppTitle('Seu dispositivo está sem internet.', textAling: TextAlign.center)),
                    SizedBox(
                        width: double.infinity,
                        child: AppTitle('Tente novamente mais tarde.', textAling: TextAlign.center)),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => {
                          
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 14,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text('Ok'),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}