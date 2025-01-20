import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Google extends StatelessWidget {
  final  imagePath;
  final Function()? onTap;
  const Google({
    super.key,
     this.imagePath,
     this.onTap,
});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
     child:  Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent),
      child: Image.asset(
        imagePath,
        height: 40,
      ),
      ),
    );
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('imagePath', imagePath));
    properties.add(DiagnosticsProperty('imagePath', imagePath));
    properties.add(DiagnosticsProperty('imagePath', imagePath));
  }
}
