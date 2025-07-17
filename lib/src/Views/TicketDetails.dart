import 'package:flutter/material.dart';
import '../helpers/consts.dart';
import '../models/Ticket.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class Ticketdetails extends StatelessWidget {
  final Ticket ticket;
  const Ticketdetails({required this.ticket});

  // Fonction pour télécharger un fichier
  Future<void> _downloadFile(BuildContext context, String fileName) async {
    try {
      // Afficher un indicateur de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Téléchargement en cours...')),
      );

      final String fileUrl = '$serverUrl/uploads/$fileName';
      
      // Utiliser Dio pour télécharger le fichier
      final dio = Dio();
      
      // Gestion différente pour les appareils physiques et virtuels
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Pour Android, essayer d'abord avec les permissions
        try {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
          
          if (status.isGranted) {
            directory = await getExternalStorageDirectory();
          } else {
            // Fallback pour les appareils virtuels ou sans permissions
            directory = await getApplicationDocumentsDirectory();
          }
        } catch (e) {
          // En cas d'erreur de permission, utiliser le dossier de l'application
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory != null) {
        // Créer un sous-dossier "downloads" s'il n'existe pas
        final downloadDir = Directory('${directory.path}/downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        
        final savePath = '${downloadDir.path}/$fileName';
        
        // Afficher un dialogue de progression
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Téléchargement en cours'),
              content: Row(
                children: [
                  CircularProgressIndicator(color: Color(0xFF4A6FE5)),
                  SizedBox(width: 20),
                  Expanded(child: Text('Téléchargement de $fileName...')),
                ],
              ),
            );
          },
        );
        
        try {
          await dio.download(
            fileUrl,
            savePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                // Vous pourriez mettre à jour la barre de progression ici
                print('${(received / total * 100).toStringAsFixed(0)}%');
              }
            },
          );
          
          // Fermer le dialogue de progression
          Navigator.of(context, rootNavigator: true).pop();
          
          
          
          // Afficher des détails supplémentaires dans un dialogue
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Téléchargement terminé'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fichier: $fileName'),
                    SizedBox(height: 8),
                    Text('Emplacement: $savePath'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Fermer'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF4A6FE5),
                    ),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          // Fermer le dialogue de progression en cas d'erreur
          Navigator.of(context, rootNavigator: true).pop();
          throw e;
        }
      } else {
        throw Exception("Impossible d'accéder au répertoire de stockage");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      print('Erreur de téléchargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        // Utilisation de constraints au lieu d'une hauteur fixe
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Permet au Column de s'ajuster à son contenu
          children: [
            // En-tête avec dégradé
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A6FE5),
                    Color(0xFF6F8FF2),
                    Color(0xFFB6C5F8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              // En-tête avec informations utilisateur sur le fond en dégradé
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: ticket.helpdeskUser?.image?.fileName != null
                          ? NetworkImage('$serverUrl/uploads/${ticket.helpdeskUser?.image?.fileName}')
                          : null,
                      child: ticket.helpdeskUser?.image?.fileName == null
                          ? Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${ticket.helpdeskUser?.firstName} ${ticket.helpdeskUser?.lastName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "UserHelpdesk",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Corps du ticket avec fond blanc - Utilisation d'Expanded à l'intérieur d'un Flexible
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                // Utilisation d'un ListView au lieu de SingleChildScrollView pour un meilleur contrôle du défilement
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true, // Permet au ListView de s'adapter au contenu
                  children: [
                    // Informations ticket
                    _buildSectionTitle('Détails du ticket'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoItem(Icons.title, 'Titre', ticket.title),
                      _buildInfoItem(Icons.category, 'Type', ticket.typeTicket),
                      _buildInfoItem(Icons.priority_high, 'Priorité', ticket.niveauEscalade ?? "-"),
                      _buildInfoItem(Icons.check_circle_outline, 'Statut', ticket.status),
                      _buildInfoItem(Icons.calendar_today, 'Date', ticket.creationDate.toIso8601String().substring(0, 10)),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Section fichiers attachés
                    _buildSectionTitle('Fichiers attachés'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ticket.listOfFiles != null && ticket.listOfFiles!.isNotEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: ticket.listOfFiles!.map((file) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(  // Ajout de InkWell pour gérer le clic
                                  onTap: () => _downloadFile(context, file.fileName),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4A6FE5).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.attach_file,
                                            color: const Color(0xFF4A6FE5),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            file.fileName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF4A6FE5),
                                              decoration: TextDecoration.underline,  // Souligner pour indiquer que c'est cliquable
                                            ),
                                          ),
                                        ),
                                        // Ajout d'une icône de téléchargement
                                        Icon(
                                          Icons.download,
                                          color: const Color(0xFF4A6FE5),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )).toList(),
                            )
                          : Text(
                              "Aucun fichier",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                    ),
                    
                    // Équipement associé si disponible
                    if (ticket.typeTicket == 'equipment' && ticket.equipmentHelpdesk != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildSectionTitle('Équipement concerné'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: ticket.equipmentHelpdesk?.typeEquipment?.logo?.fileName != null
                                      ? NetworkImage('$serverUrl/uploads/${ticket.equipmentHelpdesk!.typeEquipment!.logo!.fileName}')
                                      : null,
                                  child: ticket.equipmentHelpdesk?.typeEquipment?.logo?.fileName == null
                                      ? Icon(Icons.devices, size: 24, color: const Color(0xFF4A6FE5))
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.equipmentHelpdesk!.designation,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "SN: ${ticket.equipmentHelpdesk!.serialNumber}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // Bouton de fermeture
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                       
                        label: const Text(
                          "Fermer",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6FE5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Nouvelles méthodes d'assistance pour le design
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A6FE5),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A6FE5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A6FE5),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}