import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:helpdesk/src/controllers/sessionController.dart';

import '../service/AuthService.dart';
import 'consts.dart';

Widget buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.visible,
        ),
      ),
    ],
  );
}

//Menu

class MenuWidget extends StatefulWidget {
  final int currentIndex;

  const MenuWidget({super.key, required this.currentIndex});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A6FE5),
              Color(0xFF6F8FF2),
              Color(0xFFB6C5F8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              left: -30,
              top: 70,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 150,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Header avec logo
                Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logoBlue.png',
                        height: 60,
                      ),
                    ),
                  ),
                ),

                // Navigation
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A6FE5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "MENU PRINCIPAL",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6FE5),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                         // Dashboard
                        _buildAnimatedMenuItem(
                          icon: Icons.dashboard_outlined,
                          title: 'Dashboard',
                          isSelected: widget.currentIndex == 1,
                          route: '/dashboard',
                        ),
                         // All Ticket
                        _buildAnimatedMenuItem(
                          icon: Icons.list_alt_outlined,
                          title: 'Helpdesk Ticket',
                          isSelected: widget.currentIndex == 2,
                          route: '/tickets',
                        ),
                        // Technician accounts
                        _buildAnimatedMenuItem(
                          icon: Icons.people,
                          title: 'Technician accounts',
                          isSelected: widget.currentIndex == 3,
                          route: '/technician_accounts',
                        ),

                         // user accounts
                        _buildAnimatedMenuItem(
                          icon: Icons.people,
                          title: 'User accounts',
                          isSelected: widget.currentIndex == 33,
                          route: '/user_account',
                        ),

                        // Equipment section
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            onExpansionChanged: (_) => _toggleExpansion(),
                            leading: Icon(
                              Icons.devices_other,
                              color: _isExpanded
                                  ? const Color(0xFF4A6FE5)
                                  : Colors.blueGrey,
                            ),
                            title: Text('Equipment',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: _isExpanded
                                      ? const Color(0xFF4A6FE5)
                                      : Colors.blueGrey,
                                )),
                            childrenPadding: const EdgeInsets.only(left: 20),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            backgroundColor: Colors.transparent,
                            collapsedIconColor: Colors.blueGrey,
                            iconColor: const Color(0xFF4A6FE5),
                            children: [
                              // Equipment Type
                              _buildAnimatedMenuItem(
                                icon: Icons.category,
                                title: 'Equipment Type',
                                isSelected: widget.currentIndex == 4,
                                route: '/typeEquip',
                              ),
                              // Equipment List
                              _buildAnimatedMenuItem(
                                icon: Icons.devices,
                                title: 'Equipment List',
                                isSelected: widget.currentIndex == 5,
                                route: '/equipement',
                              ),
                            ],
                          ),
                        ),

                        // Knowledge Base
                        _buildAnimatedMenuItem(
                          icon: Icons.library_books,
                          title: 'Knowledge Base',
                          isSelected: widget.currentIndex == 6,
                          route: '/knowledge',
                        ),
                        _buildAnimatedMenuItem(
                          icon: Icons.library_books,
                          title: 'Profile',
                          isSelected: widget.currentIndex == 7,
                          route: '/profile',
                        ),
                        _buildAnimatedMenuItem(
                          icon: Icons.library_books,
                          title: 'Logout',
                          isSelected: widget.currentIndex == 8,
                          route: '/logout',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required String route,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 0 - (1 - value) * 20, 0),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.toNamed(route),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A6FE5).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFF4A6FE5).withOpacity(0.3),
                            width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: const Color(0xFF4A6FE5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Icon(
                          icon,
                          color: isSelected
                              ? const Color(0xFF4A6FE5)
                              : Colors.blueGrey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF4A6FE5)
                              : Colors.blueGrey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Container(
                          width: 5,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A6FE5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MenuUser extends StatefulWidget {
  final int Index;

  const MenuUser({super.key, required this.Index});

  @override
  State<MenuUser> createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final storage = FlutterSecureStorage();
    String? role = await storage.read(key: USER_ROLE);
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A6FE5),
              Color(0xFF6F8FF2),
              Color(0xFFB6C5F8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              left: -30,
              top: 70,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 150,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Header avec logo
                Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logoBlue.png',
                        height: 60,
                      ),
                    ),
                  ),
                ),

                // Navigation
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 5,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A6FE5),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "NAVIGATION",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6FE5),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dashboard
                        _buildMenuItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard',
                          isSelected: widget.Index == 0,
                          onTap: () {
                            if (userRole == 'technician') {
                              Get.toNamed('/technicianDashboard');
                            } else {
                              Get.toNamed('/clientDashboard');
                            }
                          },
                        ),

                        // ExpansionTile Helpdesk
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            leading: const Icon(
                              Icons.help,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                            title: const Text(
                              'Helpdesk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF444444),
                              ),
                            ),
                            iconColor: Colors.blue,
                            collapsedIconColor: const Color(0xFF666666),
                            childrenPadding: const EdgeInsets.only(left: 16),
                            children: [
                              // Helpdesk Tickets
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                leading: const Icon(
                                  Icons.list_alt,
                                  color: Color(0xFF666666),
                                  size: 20,
                                ),
                                title: const Text(
                                  'My Tickets',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                                selected: widget.Index == 1,
                                selectedColor: Colors.blue,
                                selectedTileColor: Colors.blue.withOpacity(0.1),
                                onTap: () async {
                                  Get.toNamed('/ticketUser');
                                },
                              ),
                              if (userRole == 'technician')
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  leading: const Icon(
                                    Icons.list_alt,
                                    color: Color(0xFF666666),
                                    size: 20,
                                  ),
                                  title: const Text(
                                    'Assign Tickets',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF444444),
                                    ),
                                  ),
                                  selected: widget.Index == 2,
                                  selectedColor: Colors.blue,
                                  selectedTileColor:
                                      Colors.blue.withOpacity(0.1),
                                  onTap: () async {
                                    Get.toNamed('/ticketByTech');
                                  },
                                ),
                            ],
                          ),
                        ),
                        // Knowledge Base - uniquement pour le rôle 'technician'
                        if (userRole == 'technician')
                          _buildMenuItem(
                            icon: Icons.library_books,
                            title: 'Knowledge Base',
                            isSelected: widget.Index == 3,
                            onTap: () => Get.toNamed('/knowledge'),
                          ),

                        // Profile
                        _buildMenuItem(
                          icon: Icons.person,
                          title: 'Profile',
                          isSelected: widget.Index == 4,
                          onTap: () => Get.toNamed('/profileUser'),
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: 'Deconnexion',
                          isSelected: widget.Index == 5,
                          onTap: () => Authservice.logout(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour créer les éléments du menu avec un design amélioré
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : const Color(0xFF666666),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue : const Color(0xFF444444),
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.blue,
        onTap: onTap,
        trailing: isSelected
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : null,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final sessionController session = Get.find<sessionController>();

  CustomBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == selectedIndex) return;

        switch (index) {
          case 0:
            Get.toNamed('/dashboard');
            break;
          case 1:
            Get.toNamed('/tickets');
            break;
          case 2:
            Get.toNamed('/knowledge');
            break;
          
        }
      },
      elevation: 0,
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4A6FE5),
      unselectedItemColor: Colors.grey.shade400,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Knowledge Base',
        ),
      ],
    );
  }
}
