// lib/quiz_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/question_model.dart';

class QuizScreen extends StatefulWidget {
  final String apiUrl;

  QuizScreen({required this.apiUrl});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _isLoading = true;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse(widget.apiUrl);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _questions = Question.fromJsonList(jsonData['results']);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void _nextQuestion() {
    if (_selectedAnswer != null) {
      setState(() {
        if (_questions[_currentQuestionIndex].answers[_selectedAnswer!] ==
            _questions[_currentQuestionIndex].correctAnswer) {
          _score++;
        }
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });

      if (_currentQuestionIndex >= _questions.length) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(score: _score, totalQuestions: _questions.length),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _currentQuestionIndex < _questions.length
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Question ${_currentQuestionIndex + 1}:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex].question,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ..._questions[_currentQuestionIndex].answers.map((answer) {
              int index = _questions[_currentQuestionIndex].answers.indexOf(answer);
              return ListTile(
                title: Text(answer),
                leading: Radio<int>(
                  value: index,
                  groupValue: _selectedAnswer,
                  onChanged: (int? value) {
                    setState(() {
                      _selectedAnswer = value;
                    });
                  },
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextQuestion,
              child: Text('Next'),
            ),
          ],
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  ResultScreen({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Score: $score/$totalQuestions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'You did well! Keep it up.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
