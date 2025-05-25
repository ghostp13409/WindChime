class Quote {
  final String text;
  final String author;

  const Quote({
    required this.text,
    required this.author,
  });

  Quote.fromJson(Map<String, dynamic> json)
      : text = (json['q'] ?? json['text']).toString(),
        author = (json['a'] ?? json['author']).toString();

  Map<String, dynamic> toJson() => {
        'q': text,
        'a': author,
      };

  @override
  String toString() => '{text: $text, author: $author}';
}
