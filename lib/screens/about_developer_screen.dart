import 'package:flutter/material.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      appBar: AppBar(
        title: const Text(
          'About Wedding Register Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ==================================================
            // APP TITLE
            // ==================================================

            const Text(
              'Wedding Register Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Wedding Management System',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // RAJ KUMAR PAL LOGO
            // ==================================================

            Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9933),
                    Color(0xFFFFFFFF),
                    Color(0xFF138808),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              padding: const EdgeInsets.all(5),

              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),

                child: const Center(
                  child: Text(
                    'RKP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB71C1C),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Developed By',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Raj Kumar Pal',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SHUATS CARD
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: const Color(0xFFFF9933),
                  width: 1.5,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),

              child: Column(
                children: [

                  // College Logo
                  Image.asset(
                    'assets/images/shuats_logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'College',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Sam Higginbottom University of Agriculture, '
                    'Technology and Sciences (SHUATS)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Divider(),

                  const SizedBox(height: 10),

                  const Text(
                    '📍 Prayagraj, Uttar Pradesh, India',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // INDIAN FLAG COLOUR BAR
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: Container(
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9933),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 7,
                    color: Colors.white,
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF138808),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              '© Wedding Register Pro',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Developed by Raj Kumar Pal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
