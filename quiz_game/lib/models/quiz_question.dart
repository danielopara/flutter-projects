class QuizQuestion {
  const QuizQuestion(this.question, this.answers);

  final String question;
  final List<String> answers;

  List<String> getShuffledAnswers() {
    final shuffledAnwers = List.of(answers);
    shuffledAnwers.shuffle();
    return shuffledAnwers;
  }
}
