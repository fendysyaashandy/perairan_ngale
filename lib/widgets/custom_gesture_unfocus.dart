import 'package:flutter/cupertino.dart';

class CustomGestureUnfocus extends StatelessWidget {
  const CustomGestureUnfocus({required this.child, super.key});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      FocusScope.of(context).unfocus();
    }, child: child,);
  }
}
