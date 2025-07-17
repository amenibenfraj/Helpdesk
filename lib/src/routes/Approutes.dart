import 'package:get/get.dart';
import 'package:helpdesk/src/Views/ChangePWdScreen.dart';
import 'package:helpdesk/src/Views/EquipementTypeListScreen.dart';
import 'package:helpdesk/src/Views/TicketList.dart';
import 'package:helpdesk/src/Views/Widget/SecurityAdmin.dart';
import 'package:helpdesk/src/Views/chatScreen.dart';
import 'package:helpdesk/src/Views/dashboard/DashboardScreen.dart';
import 'package:helpdesk/src/Views/knowledgeBaseScreen.dart';
import 'package:helpdesk/src/Views/listTicketByTechnicien.dart';
import 'package:helpdesk/src/Views/listTicketByUser.dart';
import 'package:helpdesk/src/Views/updateTicketForm.dart';
import 'package:helpdesk/src/helpers/utils.dart';
import 'package:helpdesk/src/models/Ticket.dart';
import '../Views/DashboardTechScreen.dart';
import '../Views/DashboaredClient.dart';
import '../Views/ListTechnicienScreen.dart';
import '../Views/ListUserScreen.dart';
import '../Views/editTypeEquip.dart';
import '../Views/equipementScreen.dart';
import '../Views/login.dart';

import '../Views/profileScreen.dart';
import '../Views/profileUserScreen.dart';
import '../Views/signupScreen.dart';
import '../models/TypeEquipment.dart';
import '../models/technician.dart';
import '../service/AuthService.dart';


class AppRoutes {
  List<Technician> technicians = [];
  static String login = '/login';
  static String logout = '/logout';
  static String dashboard = '/dashboard';
  static String technicianAccounts = '/technician_accounts';
  static String technicianDashboard = '/technicianDashboard';
  static String clientDashboard = '/clientDashboard';
  static String addUser = '/AddUser';
  static String userAccount = '/user_account';
  static String adminProfile = '/profile';
  static String equipements = '/equipement';
  static String securityuser = '/securityuser';
  static String typeEquip = '/typeEquip';
  static String Tickets = '/tickets';
  static String register = '/register';
  static String editEquipmentType = '/editEquipmentType';
  static String chat = '/chat';
  static String detailUser = '/profileUser';
  static String ticketByTech = '/ticketByTech';
  static String ticketUser = '/ticketUser';
  static String securityadmin = '/securityadmin';
  static String adminsidebar = '/adminsidebar';
  static String usersidebar = '/usersidebar';
  static String knowledge = '/knowledge';
  static String editTicket = '/editTicket';
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(
  name: AppRoutes.logout,
  page: () {
    Authservice.logout(); 
    return LoginScreen(); 
  },
),
    GetPage(name: AppRoutes.dashboard, page: () =>  DashboardScreen()),
    GetPage(
        name: AppRoutes.technicianAccounts, page: () => TechnicianListScreen()),
   GetPage(
  name: AppRoutes.technicianDashboard, 
  page: () => DashboardTechScreen() 
),
    GetPage(name: AppRoutes.clientDashboard, page: () => DashboaredClient()),
    GetPage(name: AppRoutes.userAccount, page: () => UserListScreen()),
    GetPage(name: AppRoutes.adminProfile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.detailUser, page: () => DetailUserScreen()),
    GetPage(name: AppRoutes.equipements, page: () => EquipmentListScreen()),
    GetPage(name: AppRoutes.securityuser, page: () => SecurityUser()),
    GetPage(name: AppRoutes.typeEquip, page: () => EquipmentTypeListScreen()),
    GetPage(name: AppRoutes.Tickets, page: () => Ticketlist()),
    GetPage(name: AppRoutes.register, page: () => SignUpPage()),
    GetPage(
      name: editEquipmentType,
      page: () {
        // Récupérer les arguments passés
        TypeEquipment? typeEquipment = Get.arguments;
        // Retourner la page avec l'argument
        return EditEquipmentTypeForm(typeEquipment: typeEquipment);
      },
    ),
    GetPage(
        name: AppRoutes.chat,
        page: () {
          String ticketId = Get.arguments;
          return ChatScreen(ticketId: ticketId);
        }),
    GetPage(name: AppRoutes.ticketByTech, page: () => Listticketbytechnicien()),
    GetPage(name: AppRoutes.ticketUser, page: () => ListticketbyUser()),
    GetPage(name: AppRoutes.securityadmin, page: () => SecurityAdmin()),
    GetPage(
        name: AppRoutes.adminsidebar,
        page: () => MenuWidget(
              currentIndex: 0,
            )),
    GetPage(
        name: AppRoutes.usersidebar,
        page: () => MenuUser(
              Index: 0,
            )),
    GetPage(name: AppRoutes.knowledge, page: () => KnowledgeBaseScreen()),
    GetPage(
        name: AppRoutes.editTicket,
        page: () {
          Ticket ticket = Get.arguments;
          return UpdateTicketForm(ticket: ticket);
        }),
  ];
}
