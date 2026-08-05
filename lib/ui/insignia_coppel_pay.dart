import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Insignia visual que indica si un negocio acepta Coppel Pay.
class InsigniaCoppelPay extends StatelessWidget {
  final bool compacto;

  const InsigniaCoppelPay({super.key, this.compacto = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 8 : 12,
        vertical: compacto ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: LocaliaTheme.coppelYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.payment_rounded, size: 14, color: Colors.black),
          const SizedBox(width: 5),
          Text(
            "Coppel Pay",
            style: TextStyle(
              color: Colors.black,
              fontSize: compacto ? 10 : 12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
