import &#39;package:flutter/material.dart&#39;;
import &#39;../theme/app_theme.dart&#39;;

class ProfileScreen extends StatelessWidget {
const ProfileScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF8F9FA),
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
title: const Text(
&quot;Mi Perfil Localia&quot;,
style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900,
letterSpacing: -0.5),
),
centerTitle: true,
actions: [

IconButton(
icon: const Icon(Icons.settings_rounded, color: Colors.black87),
onPressed: () {},
)
],
),
body: SingleChildScrollView(
child: Column(
children: [
Container(
width: double.infinity,
color: Colors.white,
padding: const EdgeInsets.only(bottom: 30, top: 20),
child: _buildProfileHeader(),
),
const SizedBox(height: 10),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(&quot;ESTADÍSTICAS&quot;, style: TextStyle(color: Colors.grey,
fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
const SizedBox(height: 15),
_buildStatsRow(),
const SizedBox(height: 30),
const Text(&quot;PREFERENCIAS DE VIAJE&quot;, style: TextStyle(color:
Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),

const SizedBox(height: 15),
_buildPreferencesSection(),
const SizedBox(height: 40),
_buildSupportButton(),
const SizedBox(height: 40),
],
),
),
],
),
),
);
}

Widget _buildProfileHeader() {
return Column(
children: [
Stack(
alignment: Alignment.bottomRight,
children: [
CircleAvatar(
radius: 55,
backgroundColor: LocaliaTheme.coppelYellow.withOpacity(0.3),
child: const Icon(Icons.person_rounded, size: 50, color:
LocaliaTheme.coppelGreen),
),
Container(

padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: LocaliaTheme.coppelGreen,
shape: BoxShape.circle,
border: Border.all(color: Colors.white, width: 3),
),
child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
),
],
),
const SizedBox(height: 20),
const Text(
&quot;Óscar Granados&quot;,
style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color:
Colors.black87, letterSpacing: -0.5),
),
const SizedBox(height: 6),
const Text(
&quot;Turista Localia • Abasolo, Gto.&quot;,
style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight:
FontWeight.w500),
),
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
decoration: BoxDecoration(
color: LocaliaTheme.coppelGreen.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),

),
child: const Text(
&quot;Ingeniería de Software&quot;,
style: TextStyle(color: LocaliaTheme.coppelGreen, fontWeight:
FontWeight.w700, fontSize: 13),
),
),
],
);
}

Widget _buildStatsRow() {
return Row(
children: [
Expanded(child: _buildStatCard(Icons.star_rounded, &quot;Reseñas&quot;, &quot;12&quot;,
Colors.amber)),
const SizedBox(width: 15),
Expanded(child: _buildStatCard(Icons.storefront_rounded, &quot;Visitados&quot;, &quot;8&quot;,
LocaliaTheme.coppelGreen)),
],
);
}

Widget _buildStatCard(IconData icon, String title, String value, Color iconColor) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,

borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.grey.shade200),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(icon, color: iconColor, size: 28),
const SizedBox(height: 12),
Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
color: Colors.black87)),
const SizedBox(height: 4),
Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight:
FontWeight.w500)),
],
),
);
}

Widget _buildPreferencesSection() {
final List&lt;String&gt; tags = [&#39;Gastronomía&#39;, &#39;Artesanías&#39;, &#39;Aventura&#39;, &#39;Cultura&#39;, &#39;Zonas
Arqueológicas&#39;];
return Wrap(
spacing: 10,
runSpacing: 10,
children: tags.map((tag) =&gt; Chip(
label: Text(tag, style: const TextStyle(fontWeight: FontWeight.w600, fontSize:
13)),
backgroundColor: Colors.white,

side: BorderSide(color: Colors.grey.shade300),
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
)).toList(),
);
}

Widget _buildSupportButton() {
return SizedBox(
width: double.infinity,
child: OutlinedButton.icon(
style: OutlinedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 16),
side: const BorderSide(color: LocaliaTheme.coppelGreen),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
),
icon: const Icon(Icons.help_outline_rounded, color:
LocaliaTheme.coppelGreen),
label: const Text(&quot;Centro de Ayuda Localia&quot;, style: TextStyle(color:
LocaliaTheme.coppelGreen, fontWeight: FontWeight.bold, fontSize: 15)),
onPressed: () {},
),
);
}
}
