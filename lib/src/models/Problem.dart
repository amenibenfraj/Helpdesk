class Problem {
  String id, nomProblem;
  String? description;

  Problem(
      {required this.id,  this.description, required this.nomProblem});

  factory Problem.fromJson(Map<String, dynamic> data) {
    return Problem(
        id: data['_id'],
        description: data['description'] ?? '',
        nomProblem: data['nomProblem'] ?? '');
  }
  Map<String, dynamic> toJson() {
    return {'_id': id, 'description': description, 'nomProblem': nomProblem};
  }
}
