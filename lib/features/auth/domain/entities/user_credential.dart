class UserCredential {
  final String pin;
  final String answer1;
  final String answer2;
  final String answer3;

  UserCredential({
    required this.pin,
    this.answer1 = '',
    this.answer2 = '',
    this.answer3 = '',
  });
}