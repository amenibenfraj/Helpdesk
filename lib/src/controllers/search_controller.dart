import 'package:get/get.dart';

class SearchController extends GetxController {
  var searchText = ''.obs; // La valeur de la recherche observable

  // Méthode pour mettre à jour la valeur de recherche
  void updateSearch(String query) {
    searchText.value = query;
  }

  // Méthode pour réinitialiser la recherche
  void clearSearch() {
    searchText.value = '';
  }
}
