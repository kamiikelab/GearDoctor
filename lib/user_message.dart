class UserMessage implements Exception {
  const UserMessage(this.text);

  final String text;

  @override
  String toString() => text;
}
