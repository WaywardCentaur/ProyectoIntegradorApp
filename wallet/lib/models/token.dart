class Token {
  final String owner;
  final String image;
  final String title;
  final String subject;
  final String nrc;
  final String professor;
  final String date;
  final String rank;
  final String details;

  Token(this.owner, this.image, this.title, this.subject, this.nrc,
      this.professor, this.date, this.rank, this.details);

  Token.fromJson(Map<String, dynamic> json)
      : owner = json['owner'],
        image = json['image'],
        title = json['title'],
        subject = json['subject'],
        nrc = json['nrc'],
        professor = json['professor'],
        date = json['date'],
        rank = json['rank'],
        details = json['details'];

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'image': image,
        'title': title,
        'subject': subject,
        'nrc': nrc,
        'professor': professor,
        'date': date,
        'rank': rank,
        'details': details,
      };
}
