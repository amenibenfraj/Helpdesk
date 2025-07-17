class FileModel{
    String title;
    String fileName;
    DateTime? uploadDate;
    String path;
    FileModel({required this.title,required this.fileName,DateTime? uploadDate,required this.path}):uploadDate=uploadDate??DateTime.now();

    factory FileModel.fromJson(Map<String,dynamic>json){
        return FileModel(
            title: json['title']??'',
            fileName: json['fileName']??'',
            uploadDate: json['uploadDate'] != null 
          ? DateTime.parse(json['uploadDate']) 
          : null,//l'api retourne une Date sous forme de String donc String ==> objet DateTime
            path: json['path']??''
        );
    }

    Map<String,dynamic>toJson(){
        return{
            'title':title,
            'fileName':fileName,
            'uploadDate': uploadDate?.toIso8601String(), // Convertir DateTime en String
            'path':path
        };
    }
}